import { Injectable, UnauthorizedException } from '@nestjs/common';
import { SupabaseService } from './supabase.service';
import { SupabaseUserService } from './supabase-user.service';
import { User } from '../../entities/user.entity';
import { JwtPayload } from '../auth/interfaces/jwt-payload.interface';
import { LoginResponseDto } from '../auth/dto/login-response.dto';

/**
 * Supabase Kimlik Doğrulama Servisi
 * 
 * Supabase üzerinde kimlik doğrulama işlemlerini gerçekleştiren servis
 */
@Injectable()
export class SupabaseAuthService {
  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly supabaseUserService: SupabaseUserService,
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
    // Supabase Auth ile giriş yap
    const { data, error } = await this.supabaseService.getAuth().signInWithPassword({
      email,
      password,
    });

    if (error) {
      throw new UnauthorizedException('Geçersiz kimlik bilgileri');
    }

    // Kullanıcı bilgilerini getir
    const user = await this.supabaseUserService.findById(data.user.id);
    
    // Son giriş tarihini güncelle
    await this.supabaseUserService.updateLastLogin(user.id);
    
    return user;
  }

  /**
   * Kullanıcı girişi yapar ve JWT token üretir
   * 
   * @param user - Doğrulanmış kullanıcı
   * @returns JWT token ve kullanıcı bilgileri
   */
  async login(user: User): Promise<LoginResponseDto> {
    // Supabase Auth ile oturum aç ve token al
    const { data, error } = await this.supabaseService.getAuth().admin.generateLink({
      type: 'magiclink',
      email: user.email,
    });

    if (error) {
      throw new Error(`Supabase Auth hatası: ${error.message}`);
    }

    // Token ve kullanıcı bilgilerini döndür
    return {
      accessToken: data.properties.access_token,
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
    return this.supabaseUserService.findById(payload.sub);
  }

  /**
   * Kullanıcı çıkışı yapar
   * 
   * @param token - JWT token
   * @returns İşlem sonucu
   */
  async logout(token: string): Promise<void> {
    const { error } = await this.supabaseService.getAuth().signOut();
    
    if (error) {
      throw new Error(`Supabase Auth hatası: ${error.message}`);
    }
  }

  /**
   * Parola sıfırlama e-postası gönderir
   * 
   * @param email - Kullanıcı e-posta adresi
   * @returns İşlem sonucu
   */
  async sendPasswordResetEmail(email: string): Promise<void> {
    const { error } = await this.supabaseService.getAuth().resetPasswordForEmail(email);
    
    if (error) {
      throw new Error(`Supabase Auth hatası: ${error.message}`);
    }
  }

  /**
   * Parolayı sıfırlar
   * 
   * @param token - Sıfırlama token'ı
   * @param newPassword - Yeni parola
   * @returns İşlem sonucu
   */
  async resetPassword(token: string, newPassword: string): Promise<void> {
    const { error } = await this.supabaseService.getAuth().updateUser({
      password: newPassword,
    });
    
    if (error) {
      throw new Error(`Supabase Auth hatası: ${error.message}`);
    }
  }

  /**
   * E-posta adresini doğrular
   * 
   * @param token - Doğrulama token'ı
   * @returns İşlem sonucu
   */
  async verifyEmail(token: string): Promise<void> {
    // Supabase Auth ile e-posta doğrulama işlemi
    // Not: Supabase bu işlemi otomatik olarak yönetir
  }
} 