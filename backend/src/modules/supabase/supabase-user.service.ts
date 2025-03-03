import { Injectable } from '@nestjs/common';
import { SupabaseService } from './supabase.service';
import { User } from '../../entities/user.entity';
import { CreateUserDto } from '../user/dto/create-user.dto';
import { UpdateUserDto } from '../user/dto/update-user.dto';
import { UserStatus } from '../../interfaces/user-status.enum';
import { Role } from '../../interfaces/role.enum';

/**
 * Supabase Kullanıcı Servisi
 * 
 * Supabase üzerinde kullanıcı yönetimi işlemlerini gerçekleştiren servis
 */
@Injectable()
export class SupabaseUserService {
  constructor(private readonly supabaseService: SupabaseService) {}

  /**
   * Yeni bir kullanıcı oluşturur
   * 
   * @param createUserDto - Kullanıcı oluşturma DTO'su
   * @returns Oluşturulan kullanıcı
   */
  async create(createUserDto: CreateUserDto): Promise<User> {
    // Supabase Auth ile kullanıcı oluştur
    const { data: authData, error: authError } = await this.supabaseService.getAuth().signUp({
      email: createUserDto.email,
      password: createUserDto.password,
    });

    if (authError) {
      throw new Error(`Supabase Auth hatası: ${authError.message}`);
    }

    // Kullanıcı profil bilgilerini oluştur
    const { data: userData, error: userError } = await this.supabaseService.from('users').insert({
      id: authData.user.id,
      email: createUserDto.email,
      first_name: createUserDto.firstName,
      last_name: createUserDto.lastName,
      phone_number: createUserDto.phoneNumber,
      profile_picture: createUserDto.profilePicture,
      status: UserStatus.ACTIVE,
      roles: [Role.USER],
    }).select().single();

    if (userError) {
      throw new Error(`Supabase DB hatası: ${userError.message}`);
    }

    // User entity'sine dönüştür
    return this.mapToUserEntity(userData);
  }

  /**
   * Tüm kullanıcıları getirir
   * 
   * @returns Kullanıcı listesi
   */
  async findAll(): Promise<User[]> {
    const { data, error } = await this.supabaseService.from('users').select('*');

    if (error) {
      throw new Error(`Supabase hatası: ${error.message}`);
    }

    return data.map(user => this.mapToUserEntity(user));
  }

  /**
   * ID'ye göre kullanıcı getirir
   * 
   * @param id - Kullanıcı ID'si
   * @returns Kullanıcı
   */
  async findById(id: string): Promise<User> {
    const { data, error } = await this.supabaseService.from('users')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      throw new Error(`Supabase hatası: ${error.message}`);
    }

    return this.mapToUserEntity(data);
  }

  /**
   * E-posta adresine göre kullanıcı getirir
   * 
   * @param email - Kullanıcı e-posta adresi
   * @returns Kullanıcı veya null
   */
  async findByEmail(email: string): Promise<User | null> {
    const { data, error } = await this.supabaseService.from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        // Kullanıcı bulunamadı
        return null;
      }
      throw new Error(`Supabase hatası: ${error.message}`);
    }

    return this.mapToUserEntity(data);
  }

  /**
   * Kullanıcı bilgilerini günceller
   * 
   * @param id - Kullanıcı ID'si
   * @param updateUserDto - Kullanıcı güncelleme DTO'su
   * @returns Güncellenmiş kullanıcı
   */
  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const updateData = {
      ...(updateUserDto.firstName && { first_name: updateUserDto.firstName }),
      ...(updateUserDto.lastName && { last_name: updateUserDto.lastName }),
      ...(updateUserDto.phoneNumber && { phone_number: updateUserDto.phoneNumber }),
      ...(updateUserDto.profilePicture && { profile_picture: updateUserDto.profilePicture }),
      ...(updateUserDto.language && { language: updateUserDto.language }),
      ...(updateUserDto.timezone && { timezone: updateUserDto.timezone }),
      updated_at: new Date(),
    };

    const { data, error } = await this.supabaseService.from('users')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw new Error(`Supabase hatası: ${error.message}`);
    }

    return this.mapToUserEntity(data);
  }

  /**
   * Kullanıcı parolasını günceller
   * 
   * @param id - Kullanıcı ID'si
   * @param newPassword - Yeni parola
   * @returns İşlem sonucu
   */
  async updatePassword(id: string, newPassword: string): Promise<void> {
    // Kullanıcıyı bul
    const user = await this.findById(id);

    // Supabase Auth ile parolayı güncelle
    const { error } = await this.supabaseService.getAuth().updateUser({
      password: newPassword,
    });

    if (error) {
      throw new Error(`Supabase Auth hatası: ${error.message}`);
    }
  }

  /**
   * Kullanıcı durumunu günceller
   * 
   * @param id - Kullanıcı ID'si
   * @param status - Yeni durum
   * @returns Güncellenmiş kullanıcı
   */
  async updateStatus(id: string, status: UserStatus): Promise<User> {
    const { data, error } = await this.supabaseService.from('users')
      .update({ status, updated_at: new Date() })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw new Error(`Supabase hatası: ${error.message}`);
    }

    return this.mapToUserEntity(data);
  }

  /**
   * Kullanıcıyı siler
   * 
   * @param id - Kullanıcı ID'si
   * @returns İşlem sonucu
   */
  async remove(id: string): Promise<void> {
    // Supabase Auth'dan kullanıcıyı sil
    const { error: authError } = await this.supabaseService.getAuth().admin.deleteUser(id);

    if (authError) {
      throw new Error(`Supabase Auth hatası: ${authError.message}`);
    }

    // Veritabanından kullanıcıyı sil
    const { error: dbError } = await this.supabaseService.from('users')
      .delete()
      .eq('id', id);

    if (dbError) {
      throw new Error(`Supabase DB hatası: ${dbError.message}`);
    }
  }

  /**
   * Kullanıcının son giriş tarihini günceller
   * 
   * @param id - Kullanıcı ID'si
   * @returns Güncellenmiş kullanıcı
   */
  async updateLastLogin(id: string): Promise<User> {
    const { data, error } = await this.supabaseService.from('users')
      .update({ last_login_at: new Date(), updated_at: new Date() })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw new Error(`Supabase hatası: ${error.message}`);
    }

    return this.mapToUserEntity(data);
  }

  /**
   * Supabase verisini User entity'sine dönüştürür
   * 
   * @param data - Supabase'den gelen veri
   * @returns User entity
   */
  private mapToUserEntity(data: any): User {
    const user = new User();
    user.id = data.id;
    user.email = data.email;
    user.firstName = data.first_name;
    user.lastName = data.last_name;
    user.phoneNumber = data.phone_number;
    user.profilePicture = data.profile_picture;
    user.status = data.status;
    user.roles = data.roles;
    user.language = data.language;
    user.timezone = data.timezone;
    user.lastLoginAt = data.last_login_at;
    user.createdAt = data.created_at;
    user.updatedAt = data.updated_at;
    return user;
  }
} 