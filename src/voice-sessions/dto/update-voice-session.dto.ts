import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsEnum, IsOptional } from 'class-validator';

/**
 * Sesli oturum güncellemek için kullanılan DTO sınıfı
 */
export class UpdateVoiceSessionDto {
  @ApiProperty({
    description: 'Sesli oturum durumu',
    enum: ['active', 'paused', 'ended'],
    required: false
  })
  @IsOptional()
  @IsString()
  @IsEnum(['active', 'paused', 'ended'])
  status?: string;

  @ApiProperty({
    description: 'Ses kalitesi ayarı',
    enum: ['low', 'medium', 'high'],
    required: false
  })
  @IsOptional()
  @IsString()
  @IsEnum(['low', 'medium', 'high'])
  audio_quality?: string;
} 