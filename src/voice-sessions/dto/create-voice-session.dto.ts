import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsUUID, IsString, IsEnum, IsOptional, IsInt, Min } from 'class-validator';

/**
 * Sesli oturum oluşturmak için kullanılan DTO sınıfı
 */
export class CreateVoiceSessionDto {
  @ApiProperty({
    description: 'Sesli oturumun ait olduğu tur ID',
    example: '550e8400-e29b-41d4-a716-446655440000'
  })
  @IsNotEmpty()
  @IsUUID()
  tour_id: string;

  @ApiProperty({
    description: 'Sesli oturumu başlatan kullanıcı ID',
    example: '550e8400-e29b-41d4-a716-446655440000'
  })
  @IsNotEmpty()
  @IsUUID()
  started_by: string;

  @ApiProperty({
    description: 'Sesli oturum durumu',
    enum: ['active', 'paused', 'ended'],
    default: 'active',
    required: false
  })
  @IsOptional()
  @IsString()
  @IsEnum(['active', 'paused', 'ended'])
  status?: string;

  @ApiProperty({
    description: 'Ses kalitesi ayarı',
    enum: ['low', 'medium', 'high'],
    default: 'medium',
    required: false
  })
  @IsOptional()
  @IsString()
  @IsEnum(['low', 'medium', 'high'])
  audio_quality?: string;

  @ApiProperty({
    description: 'Başlangıç katılımcı sayısı',
    default: 0,
    required: false
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  participants_count?: number;
} 