import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { SupabaseModule } from '../supabase/supabase.module';

/**
 * Kullanıcılar modülü
 * Kullanıcı yönetimiyle ilgili tüm servisleri ve kontrolörleri içerir
 */
@Module({
  imports: [SupabaseModule],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {} 