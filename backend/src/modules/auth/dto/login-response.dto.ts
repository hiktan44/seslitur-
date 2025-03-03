import { ApiProperty } from '@nestjs/swagger';
import { Role } from '../../../interfaces/role.enum';

/**
 * Kullanıcı Bilgileri DTO
 * 
 * Giriş yanıtında döndürülen kullanıcı bilgileri
 */
export class UserInfoDto {
  /**
   * Kullanıcı ID'si
   * @example "550e8400-e29b-41d4-a716-446655440000"
   */
  @ApiProperty({
    description: 'Kullanıcı ID\'si',
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  id: string;

  /**
   * Kullanıcının e-posta adresi
   * @example "kullanici@example.com"
   */
  @ApiProperty({
    description: 'Kullanıcının e-posta adresi',
    example: 'kullanici@example.com',
  })
  email: string;

  /**
   * Kullanıcının adı
   * @example "Ahmet"
   */
  @ApiProperty({
    description: 'Kullanıcının adı',
    example: 'Ahmet',
  })
  firstName: string;

  /**
   * Kullanıcının soyadı
   * @example "Yılmaz"
   */
  @ApiProperty({
    description: 'Kullanıcının soyadı',
    example: 'Yılmaz',
  })
  lastName: string;

  /**
   * Kullanıcının rolleri
   * @example ["user"]
   */
  @ApiProperty({
    description: 'Kullanıcının rolleri',
    example: ['user'],
    enum: Role,
    isArray: true,
  })
  roles: Role[];
}

/**
 * Giriş Yanıt DTO
 * 
 * Başarılı giriş sonrası döndürülen veri transfer nesnesi
 */
export class LoginResponseDto {
  /**
   * JWT erişim token'ı
   * @example "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   */
  @ApiProperty({
    description: 'JWT erişim token\'ı',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  accessToken: string;

  /**
   * Kullanıcı bilgileri
   */
  @ApiProperty({
    description: 'Kullanıcı bilgileri',
    type: UserInfoDto,
  })
  user: UserInfoDto;
} 