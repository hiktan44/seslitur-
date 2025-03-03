import { Role } from '../../../interfaces/role.enum';

/**
 * JWT Payload Arayüzü
 * 
 * JWT token içeriğini tanımlar
 */
export interface JwtPayload {
  /**
   * Kullanıcı ID'si
   */
  sub: string;
  
  /**
   * Kullanıcı e-posta adresi
   */
  email: string;
  
  /**
   * Kullanıcı rolü
   */
  role: string;
  
  /**
   * Token oluşturulma zamanı (Unix timestamp)
   */
  iat?: number;
  
  /**
   * Token son geçerlilik zamanı (Unix timestamp)
   */
  exp?: number;
} 