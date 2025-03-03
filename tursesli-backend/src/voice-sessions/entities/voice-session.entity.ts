import { ApiProperty } from '@nestjs/swagger';

export enum AudioQuality {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
}

export class VoiceSession {
  @ApiProperty({
    description: 'Sesli oturum ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  id: string;

  @ApiProperty({
    description: 'Tur ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  tour_id: string;

  @ApiProperty({
    description: 'Oturumu başlatan kullanıcı ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  started_by: string;

  @ApiProperty({
    description: 'Oturum durumu',
    example: 'active',
    enum: ['active', 'ended'],
  })
  status: string;

  @ApiProperty({
    description: 'Katılımcı sayısı',
    example: 10,
  })
  participant_count: number;

  @ApiProperty({
    description: 'Ses kalitesi',
    enum: AudioQuality,
    example: AudioQuality.MEDIUM,
  })
  audio_quality: AudioQuality;

  @ApiProperty({
    description: 'Oturumun başlangıç zamanı',
    example: '2023-01-01T12:00:00Z',
  })
  started_at: Date;

  @ApiProperty({
    description: 'Oturumun bitiş zamanı',
    example: '2023-01-01T14:00:00Z',
    nullable: true,
  })
  ended_at: Date | null;

  @ApiProperty({
    description: 'Oluşturulma zamanı',
    example: '2023-01-01T12:00:00Z',
  })
  created_at: Date;

  @ApiProperty({
    description: 'Son güncelleme zamanı',
    example: '2023-01-01T12:00:00Z',
  })
  updated_at: Date;
} 