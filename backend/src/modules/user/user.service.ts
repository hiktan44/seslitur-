import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User } from '../../entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserStatus } from '../../interfaces/user-status.enum';

/**
 * Kullanıcı Servisi
 * 
 * Kullanıcı yönetimi ile ilgili tüm işlemleri gerçekleştiren servis
 */
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /**
   * Yeni bir kullanıcı oluşturur
   * 
   * @param createUserDto - Kullanıcı oluşturma DTO'su
   * @returns Oluşturulan kullanıcı
   * @throws ConflictException - E-posta adresi zaten kullanılıyorsa
   */
  async create(createUserDto: CreateUserDto): Promise<User> {
    // E-posta adresinin benzersiz olduğunu kontrol et
    const existingUser = await this.userRepository.findOne({
      where: { email: createUserDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Bu e-posta adresi zaten kullanılıyor');
    }

    // Parolayı hashle
    const passwordHash = await bcrypt.hash(createUserDto.password, 10);

    // Yeni kullanıcı oluştur
    const user = this.userRepository.create({
      ...createUserDto,
      passwordHash,
      status: UserStatus.ACTIVE,
    });

    // Kullanıcıyı kaydet ve döndür
    return this.userRepository.save(user);
  }

  /**
   * Tüm kullanıcıları getirir
   * 
   * @returns Kullanıcı listesi
   */
  async findAll(): Promise<User[]> {
    return this.userRepository.find();
  }

  /**
   * ID'ye göre kullanıcı getirir
   * 
   * @param id - Kullanıcı ID'si
   * @returns Kullanıcı
   * @throws NotFoundException - Kullanıcı bulunamazsa
   */
  async findById(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    
    if (!user) {
      throw new NotFoundException(`${id} ID'li kullanıcı bulunamadı`);
    }
    
    return user;
  }

  /**
   * E-posta adresine göre kullanıcı getirir
   * 
   * @param email - Kullanıcı e-posta adresi
   * @returns Kullanıcı veya null
   */
  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  /**
   * Kullanıcı bilgilerini günceller
   * 
   * @param id - Kullanıcı ID'si
   * @param updateUserDto - Kullanıcı güncelleme DTO'su
   * @returns Güncellenmiş kullanıcı
   * @throws NotFoundException - Kullanıcı bulunamazsa
   */
  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    // Kullanıcının var olduğunu kontrol et
    await this.findById(id);
    
    // Kullanıcıyı güncelle
    await this.userRepository.update(id, updateUserDto);
    
    // Güncellenmiş kullanıcıyı getir ve döndür
    return this.findById(id);
  }

  /**
   * Kullanıcı parolasını günceller
   * 
   * @param id - Kullanıcı ID'si
   * @param newPassword - Yeni parola
   * @returns Güncellenmiş kullanıcı
   */
  async updatePassword(id: string, newPassword: string): Promise<User> {
    // Kullanıcının var olduğunu kontrol et
    const user = await this.findById(id);
    
    // Yeni parolayı hashle
    const passwordHash = await bcrypt.hash(newPassword, 10);
    
    // Parolayı güncelle
    await this.userRepository.update(id, { passwordHash });
    
    // Güncellenmiş kullanıcıyı döndür
    return this.findById(id);
  }

  /**
   * Kullanıcı durumunu günceller
   * 
   * @param id - Kullanıcı ID'si
   * @param status - Yeni durum
   * @returns Güncellenmiş kullanıcı
   */
  async updateStatus(id: string, status: UserStatus): Promise<User> {
    // Kullanıcının var olduğunu kontrol et
    await this.findById(id);
    
    // Durumu güncelle
    await this.userRepository.update(id, { status });
    
    // Güncellenmiş kullanıcıyı döndür
    return this.findById(id);
  }

  /**
   * Kullanıcıyı siler
   * 
   * @param id - Kullanıcı ID'si
   * @returns Silme işlemi sonucu
   */
  async remove(id: string): Promise<void> {
    // Kullanıcının var olduğunu kontrol et
    await this.findById(id);
    
    // Kullanıcıyı sil
    await this.userRepository.delete(id);
  }

  /**
   * Kullanıcının son giriş tarihini günceller
   * 
   * @param id - Kullanıcı ID'si
   * @returns Güncellenmiş kullanıcı
   */
  async updateLastLogin(id: string): Promise<User> {
    // Kullanıcının var olduğunu kontrol et
    await this.findById(id);
    
    // Son giriş tarihini güncelle
    await this.userRepository.update(id, { lastLoginAt: new Date() });
    
    // Güncellenmiş kullanıcıyı döndür
    return this.findById(id);
  }
} 