/**
 * Oturum Durumu Enum
 * 
 * Oturumun mevcut durumunu belirten enum
 */
export enum SessionStatus {
  /**
   * Planlanmış oturum
   */
  SCHEDULED = 'scheduled',
  
  /**
   * Aktif oturum
   */
  ACTIVE = 'active',
  
  /**
   * Duraklatılmış oturum
   */
  PAUSED = 'paused',
  
  /**
   * Tamamlanmış oturum
   */
  COMPLETED = 'completed',
  
  /**
   * İptal edilmiş oturum
   */
  CANCELLED = 'cancelled',
} 