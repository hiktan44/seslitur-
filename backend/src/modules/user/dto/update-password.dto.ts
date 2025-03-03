import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';

/**
 * Parola Güncelleme DTO
 * 
 * Kullanıcı parolasını güncellemek için kullanılan veri transfer nesnesi
 */
export class UpdatePasswordDto {
  /**
   * Kullanıcının mevcut parolası
   * @example "EskiParola123"
   */
  @ApiProperty({
    description: 'Kullanıcının mevcut parolası',
    example: 'EskiParola123',
  })
  @IsString({ message: 'Mevcut parola bir metin olmalıdır' })
  @IsNotEmpty({ message: 'Mevcut parola zorunludur' })
  currentPassword: string;

  /**
   * Kullanıcının yeni parolası
   * @example "YeniGuclu.Parola123"
   */
  @ApiProperty({
    description: 'Kullanıcının yeni parolası (en az 8 karakter, büyük/küçük harf ve rakam içermeli)',
    example: 'YeniGuclu.Parola123',
  })
  @IsString({ message: 'Yeni parola bir metin olmalıdır' })
  @MinLength(8, { message: 'Yeni parola en az 8 karakter olmalıdır' })
  @MaxLength(50, { message: 'Yeni parola en fazla 50 karakter olmalıdır' })
  @Matches(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
    message: 'Yeni parola en az bir büyük harf, bir küçük harf ve bir rakam içermelidir',
  })
  @IsNotEmpty({ message: 'Yeni parola zorunludur' })
  newPassword: string;

  /**
   * Yeni parolanın tekrarı
   * @example "YeniGuclu.Parola123"
   */
  @ApiProperty({
    description: 'Yeni parolanın tekrarı (yeni parola ile aynı olmalıdır)',
    example: 'YeniGuclu.Parola123',
  })
  @IsString({ message: 'Parola tekrarı bir metin olmalıdır' })
  @IsNotEmpty({ message: 'Parola tekrarı zorunludur' })
  passwordConfirmation: string;
} 