import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private readonly supabaseService: SupabaseService) {}

  /**
   * Yeni bir kullanıcı oluşturur
   * @param createUserDto Kullanıcı oluşturmak için gerekli bilgiler
   */
  async create(createUserDto: CreateUserDto) {
    // Önce Supabase Auth ile kullanıcı oluşturalım
    const { data: authData, error: authError } = await this.supabaseService
      .getClient()
      .auth.admin.createUser({
        email: createUserDto.email,
        password: createUserDto.password,
        email_confirm: true,
      });

    if (authError) throw authError;

    // Şimdi users tablosuna kaydedelim
    const userData = {
      id: authData.user.id,
      first_name: createUserDto.first_name,
      last_name: createUserDto.last_name,
      phone_number: createUserDto.phone_number,
      role: createUserDto.role,
    };

    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .insert([userData])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Tüm kullanıcıları getirir
   */
  async findAll() {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*');

    if (error) throw error;
    return data;
  }

  /**
   * Belirli bir kullanıcıyı ID'sine göre getirir
   * @param id Kullanıcı ID
   */
  async findOne(id: string) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Kullanıcı ID: ${id} bulunamadı`);
    
    return data;
  }

  /**
   * Kullanıcı bilgilerini günceller
   * @param id Güncellenecek kullanıcının ID'si
   * @param updateUserDto Güncellenecek bilgiler
   */
  async update(id: string, updateUserDto: UpdateUserDto) {
    // Supabase Auth kullanıcı bilgilerini güncelleyelim
    if (updateUserDto.email) {
      const { error: authError } = await this.supabaseService
        .getClient()
        .auth.admin.updateUserById(id, {
          email: updateUserDto.email,
        });

      if (authError) throw authError;
    }

    // Kullanıcı bilgilerini güncelleyelim
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .update({
        first_name: updateUserDto.first_name,
        last_name: updateUserDto.last_name,
        phone_number: updateUserDto.phone_number,
        role: updateUserDto.role,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Kullanıcı ID: ${id} bulunamadı`);
    
    return data;
  }

  /**
   * Kullanıcıyı siler
   * @param id Silinecek kullanıcının ID'si
   */
  async remove(id: string) {
    // Kullanıcıyı Supabase Auth'dan silelim
    const { error: authError } = await this.supabaseService
      .getClient()
      .auth.admin.deleteUser(id);

    if (authError) throw authError;

    // Kullanıcıyı users tablosundan silelim
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .delete()
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Kullanıcı ID: ${id} bulunamadı`);
    
    return { message: 'Kullanıcı başarıyla silindi' };
  }
} 