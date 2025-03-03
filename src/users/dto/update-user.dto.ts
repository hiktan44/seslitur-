import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsOptional, IsString, IsEnum } from 'class-validator';
import { UserRole } from './create-user.dto';

export class UpdateUserDto {
  @ApiProperty({
    description: 'Kullanıcının e-posta adresi',
    example: 'ornek@email.com',
    required: false,
  })
  @IsEmail()
  @IsOptional()
  email?: string;

  @ApiProperty({
    description: 'Kullanıcının adı',
    example: 'Ahmet',
    required: false,
  })
  @IsString()
  @IsOptional()
  first_name?: string;

  @ApiProperty({
    description: 'Kullanıcının soyadı',
    example: 'Yılmaz',
    required: false,
  })
  @IsString()
  @IsOptional()
  last_name?: string;

  @ApiProperty({
    description: 'Kullanıcının telefon numarası',
    example: '+905551234567',
    required: false,
  })
  @IsString()
  @IsOptional()
  phone_number?: string;

  @ApiProperty({
    description: 'Kullanıcının rolü',
    enum: UserRole,
    example: UserRole.GUIDE,
    required: false,
  })
  @IsEnum(UserRole)
  @IsOptional()
  role?: UserRole;
} 