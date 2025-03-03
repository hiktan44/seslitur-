import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, IsUUID, IsDateString, IsEnum } from 'class-validator';
import { TourStatus } from './create-tour.dto';
import { PartialType } from '@nestjs/swagger';
import { CreateTourDto } from './create-tour.dto';

export class UpdateTourDto extends PartialType(CreateTourDto) {
  // PartialType, CreateTourDto'daki tüm alanları opsiyonel yapar
} 