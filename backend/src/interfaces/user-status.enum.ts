/**
 * Kullanıcı Durumu Enum
 * 
 * Kullanıcının mevcut durumunu belirten enum
 */
export enum UserStatus {
  /**
   * Aktif kullanıcı
   */
  ACTIVE = 'active',
  
  /**
   * Pasif kullanıcı
   */
  INACTIVE = 'inactive',
  
  /**
   * Askıya alınmış kullanıcı
   */
  SUSPENDED = 'suspended',
  
  /**
   * Doğrulanmamış kullanıcı
   */
  UNVERIFIED = 'unverified',
  
  /**
   * Silinmiş kullanıcı
   */
  DELETED = 'deleted',
} 