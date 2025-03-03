import { Module } from '@nestjs/common';
import { WebrtcService } from './webrtc.service';
import { WebrtcGateway } from './webrtc.gateway';
import { VoiceSessionsModule } from '../voice-sessions/voice-sessions.module';

@Module({
  imports: [VoiceSessionsModule],
  providers: [WebrtcService, WebrtcGateway],
  exports: [WebrtcService],
})
export class WebrtcModule {} 