import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { UserService } from '../user/user.service';
import { User } from '../../entities/user.entity';
import { JwtPayload } from './interfaces/jwt-payload.interface';
import { LoginResponseDto } from './dto/login-response.dto';

/**
 * Kimlik Doğrulama Servisi
 * 
 * Kullanıcı kimlik doğrulama ve yetkilendirme işlemlerini gerçekleştiren servis
 */
@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Kullanıcı kimlik bilgilerini doğrular
   * 
   * @param email - Kullanıcı e-posta adresi
   * @param password - Kullanıcı parolası
   * @returns Doğrulanmış kullanıcı
   * @throws UnauthorizedException - Kimlik bilgileri geçersizse
   */
  async validateUser(email: string, password: string): Promise<User> {
    // E-posta adresine göre kullanıcıyı bul
    const user = await this.userService.findByEmail(email);
    
    // Kullanıcı yoksa veya pasifse hata fırlat
    if (!user || user.status !== 'active') {
      throw new UnauthorizedException('Geçersiz kimlik bilgileri');
    }
    
    // Parolayı doğrula
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    
    // Parola geçersizse hata fırlat
    if (!isPasswordValid) {
      throw new UnauthorizedException('Geçersiz kimlik bilgileri');
    }
    
    // Son giriş tarihini güncelle
    await this.userService.updateLastLogin(user.id);
    
    // Doğrulanmış kullanıcıyı döndür
    return user;
  }

  /**
   * Kullanıcı girişi yapar ve JWT token üretir
   * 
   * @param user - Doğrulanmış kullanıcı
   * @returns JWT token ve kullanıcı bilgileri
   */
  async login(user: User): Promise<LoginResponseDto> {
    // JWT payload oluştur
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      roles: user.roles,
    };
    
    // JWT token üret
    const accessToken = this.jwtService.sign(payload);
    
    // Token ve kullanıcı bilgilerini döndür
    return {
      accessToken,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        roles: user.roles,
      },
    };
  }

  /**
   * JWT token'ı doğrular ve kullanıcıyı getirir
   * 
   * @param payload - JWT payload
   * @returns Kullanıcı
   */
  async validateToken(payload: JwtPayload): Promise<User> {
    return this.userService.findById(payload.sub);
  }
} 