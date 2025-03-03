import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { ToursModule } from './tours/tours.module';
import { VoiceSessionsModule } from './voice-sessions/voice-sessions.module';
import { WebrtcModule } from './webrtc/webrtc.module';
import { SupabaseModule } from './supabase/supabase.module';

@Module({
  imports: [UsersModule, ToursModule, VoiceSessionsModule, WebrtcModule, SupabaseModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
