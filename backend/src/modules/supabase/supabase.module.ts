import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { SupabaseService } from './supabase.service';
import { SupabaseUserService } from './supabase-user.service';
import { SupabaseAuthService } from './supabase-auth.service';

/**
 * Supabase Modülü
 * 
 * Supabase servislerini ve yapılandırmasını içeren global modül
 */
@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    SupabaseService,
    SupabaseUserService,
    SupabaseAuthService,
  ],
  exports: [
    SupabaseService,
    SupabaseUserService,
    SupabaseAuthService,
  ],
})
export class SupabaseModule {} 