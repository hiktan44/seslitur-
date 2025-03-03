import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';

/**
 * Kullanıcı Oluşturma DTO
 * 
 * Yeni kullanıcı oluşturmak için kullanılan veri transfer nesnesi
 */
export class CreateUserDto {
  /**
   * Kullanıcının e-posta adresi
   * @example "kullanici@example.com"
   */
  @ApiProperty({
    description: 'Kullanıcının e-posta adresi',
    example: 'kullanici@example.com',
  })
  @IsEmail({}, { message: 'Geçerli bir e-posta adresi giriniz' })
  @IsNotEmpty({ message: 'E-posta adresi zorunludur' })
  email: string;

  /**
   * Kullanıcının parolası
   * @example "Guclu.Parola123"
   */
  @ApiProperty({
    description: 'Kullanıcının parolası (en az 8 karakter, büyük/küçük harf ve rakam içermeli)',
    example: 'Guclu.Parola123',
  })
  @IsString({ message: 'Parola bir metin olmalıdır' })
  @MinLength(8, { message: 'Parola en az 8 karakter olmalıdır' })
  @MaxLength(50, { message: 'Parola en fazla 50 karakter olmalıdır' })
  @Matches(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
    message: 'Parola en az bir büyük harf, bir küçük harf ve bir rakam içermelidir',
  })
  @IsNotEmpty({ message: 'Parola zorunludur' })
  password: string;

  /**
   * Kullanıcının adı
   * @example "Ahmet"
   */
  @ApiProperty({
    description: 'Kullanıcının adı',
    example: 'Ahmet',
  })
  @IsString({ message: 'Ad bir metin olmalıdır' })
  @IsNotEmpty({ message: 'Ad zorunludur' })
  @MinLength(2, { message: 'Ad en az 2 karakter olmalıdır' })
  @MaxLength(50, { message: 'Ad en fazla 50 karakter olmalıdır' })
  firstName: string;

  /**
   * Kullanıcının soyadı
   * @example "Yılmaz"
   */
  @ApiProperty({
    description: 'Kullanıcının soyadı',
    example: 'Yılmaz',
  })
  @IsString({ message: 'Soyad bir metin olmalıdır' })
  @IsNotEmpty({ message: 'Soyad zorunludur' })
  @MinLength(2, { message: 'Soyad en az 2 karakter olmalıdır' })
  @MaxLength(50, { message: 'Soyad en fazla 50 karakter olmalıdır' })
  lastName: string;

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
} 