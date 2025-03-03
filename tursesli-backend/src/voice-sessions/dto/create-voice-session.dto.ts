import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsUUID, IsEnum, IsOptional } from 'class-validator';
import { AudioQuality } from '../entities/voice-session.entity';

export class CreateVoiceSessionDto {
  @ApiProperty({
    description: 'Turun ID\'si',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsUUID()
  @IsNotEmpty()
  tour_id: string;

  @ApiProperty({
    description: 'Oturumu başlatan kullanıcının ID\'si',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsUUID()
  @IsNotEmpty()
  started_by: string;

  @ApiProperty({
    description: 'Oturum durumu (varsayılan olarak active)',
    example: 'active',
    default: 'active',
  })
  @IsString()
  @IsOptional()
  status?: string = 'active';

  @ApiProperty({
    description: 'Ses kalitesi',
    enum: AudioQuality,
    example: AudioQuality.MEDIUM,
    default: AudioQuality.MEDIUM,
  })
  @IsEnum(AudioQuality)
  @IsOptional()
  audio_quality?: AudioQuality = AudioQuality.MEDIUM;
}
