import { Injectable, OnModuleInit } from '@nestjs/common';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService implements OnModuleInit {
  private supabase: SupabaseClient;
  
  constructor() {}
  
  /**
   * NestJS modülü başlatıldığında Supabase istemcisini oluşturur
   */
  onModuleInit() {
    this.supabase = createClient(
      process.env.SUPABASE_URL || '',
      process.env.SUPABASE_KEY || '',
    );
    
    if (!process.env.SUPABASE_URL || !process.env.SUPABASE_KEY) {
      console.warn('⚠️ Supabase URL veya KEY tanımlanmamış. .env dosyanızı kontrol edin.');
    } else {
      console.log('✅ Supabase bağlantısı başarıyla kuruldu.');
    }
  }
  
  /**
   * Supabase istemcisini döndürür
   * @returns SupabaseClient
   */
  getClient(): SupabaseClient {
    return this.supabase;
  }
} 