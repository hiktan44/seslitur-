import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

/**
 * Giriş DTO
 * 
 * Kullanıcı girişi için kullanılan veri transfer nesnesi
 */
export class LoginDto {
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
    description: 'Kullanıcının parolası',
    example: 'Guclu.Parola123',
  })
  @IsString({ message: 'Parola bir metin olmalıdır' })
  @IsNotEmpty({ message: 'Parola zorunludur' })
  password: string;
} 