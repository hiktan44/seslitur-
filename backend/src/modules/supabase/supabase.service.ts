import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

/**
 * Supabase Servisi
 * 
 * Supabase istemcisini ve ilgili işlevleri sağlayan servis
 */
@Injectable()
export class SupabaseService implements OnModuleInit {
  private supabaseClient: SupabaseClient;

  constructor(private configService: ConfigService) {}

  /**
   * Modül başlatıldığında Supabase istemcisini oluşturur
   */
  onModuleInit() {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey = this.configService.get<string>('SUPABASE_KEY');

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Supabase yapılandırması eksik. SUPABASE_URL ve SUPABASE_KEY çevre değişkenleri gereklidir.');
    }

    this.supabaseClient = createClient(supabaseUrl, supabaseKey);
  }

  /**
   * Supabase istemcisini döndürür
   * 
   * @returns Supabase istemcisi
   */
  getClient(): SupabaseClient {
    return this.supabaseClient;
  }

  /**
   * Supabase Auth servisini döndürür
   * 
   * @returns Supabase Auth servisi
   */
  getAuth() {
    return this.supabaseClient.auth;
  }

  /**
   * Supabase Storage servisini döndürür
   * 
   * @returns Supabase Storage servisi
   */
  getStorage() {
    return this.supabaseClient.storage;
  }

  /**
   * Belirtilen tabloyu sorgular
   * 
   * @param table - Tablo adı
   * @returns Tablo sorgu oluşturucusu
   */
  from(table: string) {
    return this.supabaseClient.from(table);
  }

  /**
   * Gerçek zamanlı kanal oluşturur
   * 
   * @returns Gerçek zamanlı kanal oluşturucusu
   */
  channel() {
    return this.supabaseClient.channel('public');
  }
} 