import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsOptional, IsString, MinLength, MaxLength } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';

/**
 * Kullanıcı Güncelleme DTO
 * 
 * Kullanıcı bilgilerini güncellemek için kullanılan veri transfer nesnesi
 */
export class UpdateUserDto extends PartialType(CreateUserDto) {
  /**
   * Kullanıcının adı
   * @example "Ahmet"
   */
  @ApiProperty({
    description: 'Kullanıcının adı',
    example: 'Ahmet',
    required: false,
  })
  @IsString({ message: 'Ad bir metin olmalıdır' })
  @MinLength(2, { message: 'Ad en az 2 karakter olmalıdır' })
  @MaxLength(50, { message: 'Ad en fazla 50 karakter olmalıdır' })
  @IsOptional()
  firstName?: string;

  /**
   * Kullanıcının soyadı
   * @example "Yılmaz"
   */
  @ApiProperty({
    description: 'Kullanıcının soyadı',
    example: 'Yılmaz',
    required: false,
  })
  @IsString({ message: 'Soyad bir metin olmalıdır' })
  @MinLength(2, { message: 'Soyad en az 2 karakter olmalıdır' })
  @MaxLength(50, { message: 'Soyad en fazla 50 karakter olmalıdır' })
  @IsOptional()
  lastName?: string;

  /**
   * Kullanıcının telefon numarası
   * @example "+905551234567"
   */
  @ApiProperty({
    description: 'Kullanıcının telefon numarası',
    example: '+905551234567',
    required: false,
  })
  @IsString({ message: 'Telefon numarası bir metin olmalıdır' })
  @IsOptional()
  phoneNumber?: string;

  /**
   * Kullanıcının profil resmi URL'si
   * @example "https://example.com/profile.jpg"
   */
  @ApiProperty({
    description: 'Kullanıcının profil resmi URL\'si',
    example: 'https://example.com/profile.jpg',
    required: false,
  })
  @IsString({ message: 'Profil resmi URL\'si bir metin olmalıdır' })
  @IsOptional()
  profilePicture?: string;

  /**
   * Kullanıcının tercih ettiği dil
   * @example "tr"
   */
  @ApiProperty({
    description: 'Kullanıcının tercih ettiği dil',
    example: 'tr',
    required: false,
  })
  @IsString({ message: 'Dil bir metin olmalıdır' })
  @IsOptional()
  language?: string;

  /**
   * Kullanıcının zaman dilimi
   * @example "Europe/Istanbul"
   */
  @ApiProperty({
    description: 'Kullanıcının zaman dilimi',
    example: 'Europe/Istanbul',
    required: false,
  })
  @IsString({ message: 'Zaman dilimi bir metin olmalıdır' })
  @IsOptional()
  timezone?: string;
} 