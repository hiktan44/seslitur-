import { Module } from '@nestjs/common';
import { ToursController } from './tours.controller';
import { ToursService } from './tours.service';
import { SupabaseModule } from '../supabase/supabase.module';

/**
 * Turlar modülü
 * Turların yönetimiyle ilgili tüm servisleri ve kontrolörleri içerir
 */
@Module({
  imports: [SupabaseModule],
  controllers: [ToursController],
  providers: [ToursService],
  exports: [ToursService],
})
export class ToursModule {} 