import { Module } from '@nestjs/common';
import { VoiceSessionsController } from './voice-sessions.controller';
import { VoiceSessionsService } from './voice-sessions.service';

@Module({
  controllers: [VoiceSessionsController],
  providers: [VoiceSessionsService]
})
export class VoiceSessionsModule {}
