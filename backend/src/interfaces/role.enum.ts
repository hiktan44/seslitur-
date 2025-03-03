/**
 * Kullanıcı Rolü Enum
 * 
 * Kullanıcının sistemdeki rolünü belirten enum
 */
export enum Role {
  /**
   * Normal kullanıcı
   */
  USER = 'user',
  
  /**
   * Grup moderatörü
   */
  MODERATOR = 'moderator',
  
  /**
   * Grup yöneticisi
   */
  ADMIN = 'admin',
  
  /**
   * Sistem yöneticisi
   */
  SUPER_ADMIN = 'super_admin',
} 