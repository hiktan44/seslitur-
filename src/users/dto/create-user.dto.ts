import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, IsEnum, IsOptional } from 'class-validator';

export enum UserRole {
  GUIDE = 'guide',
  PARTICIPANT = 'participant',
}

export class CreateUserDto {
  @ApiProperty({
    description: 'Kullanıcının e-posta adresi',
    example: 'ornek@email.com',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({
    description: 'Kullanıcının adı',
    example: 'Ahmet',
  })
  @IsString()
  @IsNotEmpty()
  first_name: string;

  @ApiProperty({
    description: 'Kullanıcının soyadı',
    example: 'Yılmaz',
  })
  @IsString()
  @IsNotEmpty()
  last_name: string;

  @ApiProperty({
    description: 'Kullanıcının şifresi',
    example: 'güvenli123',
  })
  @IsString()
  @IsNotEmpty()
  password: string;

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
  })
  @IsEnum(UserRole)
  @IsNotEmpty()
  role: UserRole;
} 