import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsUUID, IsEnum, IsOptional, IsDateString } from 'class-validator';

export enum TourStatus {
  UPCOMING = 'upcoming',
  ACTIVE = 'active',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

export class CreateTourDto {
  @ApiProperty({
    description: 'Tur adı',
    example: 'İstanbul Tarihi Yarımada Turu',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'Tur kodu (benzersiz)',
    example: 'IST-001',
  })
  @IsString()
  @IsNotEmpty()
  code: string;

  @ApiProperty({
    description: 'Tur destinasyonu',
    example: 'İstanbul, Türkiye',
  })
  @IsString()
  @IsNotEmpty()
  destination: string;

  @ApiProperty({
    description: 'Tur rehberinin ID\'si',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsUUID()
  @IsNotEmpty()
  guide_id: string;

  @ApiProperty({
    description: 'Turun başlangıç tarihi (ISO formatında)',
    example: '2024-01-01T09:00:00Z',
  })
  @IsDateString()
  @IsNotEmpty()
  start_date: string;

  @ApiProperty({
    description: 'Turun bitiş tarihi (ISO formatında)',
    example: '2024-01-05T18:00:00Z',
  })
  @IsDateString()
  @IsNotEmpty()
  end_date: string;

  @ApiProperty({
    description: 'Tur durumu',
    enum: TourStatus,
    example: TourStatus.UPCOMING,
  })
  @IsEnum(TourStatus)
  @IsNotEmpty()
  status: TourStatus;

  @ApiProperty({
    description: 'Tur açıklaması',
    example: 'İstanbul\'un tarihi yarımadasını gezeceğimiz 5 günlük tur.',
    required: false,
  })
  @IsString()
  @IsOptional()
  description?: string;
} 