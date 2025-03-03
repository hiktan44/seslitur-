/**
 * Konuşma Modu Enum
 * 
 * Grup içindeki konuşma modunu belirten enum
 */
export enum TalkMode {
  /**
   * Tek konuşmacı modu - Sadece bir kişi konuşabilir
   */
  SINGLE_SPEAKER = 'single_speaker',
  
  /**
   * Moderatör kontrollü mod - Moderatör izin verdiği kişiler konuşabilir
   */
  MODERATED = 'moderated',
  
  /**
   * Serbest konuşma modu - Herkes konuşabilir
   */
  FREE = 'free',
} 