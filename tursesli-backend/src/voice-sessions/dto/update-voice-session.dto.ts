import { PartialType } from '@nestjs/swagger';
import { CreateVoiceSessionDto } from './create-voice-session.dto';

export class UpdateVoiceSessionDto extends PartialType(CreateVoiceSessionDto) {
  // PartialType, CreateVoiceSessionDto'daki tüm alanları opsiyonel yapar
}
