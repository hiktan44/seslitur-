import { Injectable } from '@nestjs/common';

/**
 * Ana uygulama servisi
 * Temel uygulama fonksiyonlarını sağlar
 */
@Injectable()
export class AppService {
  /**
   * Basit bir merhaba mesajı döndürür
   * @returns Karşılama mesajı
   */
  getHello(): string {
    return 'TurSesli API hizmetinizde!';
  }
} 