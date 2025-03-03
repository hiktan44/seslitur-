import { Module } from '@nestjs/common';
import { VoiceSessionsService } from './voice-sessions.service';
import { VoiceSessionsController } from './voice-sessions.controller';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [SupabaseModule],
  controllers: [VoiceSessionsController],
  providers: [VoiceSessionsService],
  exports: [VoiceSessionsService]
})
export class VoiceSessionsModule {} 