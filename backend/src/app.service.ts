import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Ana Uygulama Servisi
 * 
 * Temel uygulama işlevlerini sağlayan servis
 */
@Injectable()
export class AppService {
  constructor(private readonly configService: ConfigService) {}

  /**
   * Karşılama mesajı döndürür
   * 
   * @returns Karşılama mesajı
   */
  getHello() {
    return {
      message: 'Sesli İletişim Sistemi API',
      version: this.configService.get<string>('npm_package_version', '0.1.0'),
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Uygulama sağlık durumunu döndürür
   * 
   * @returns Sağlık durumu
   */
  getHealth() {
    return {
      status: 'up',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      version: this.configService.get<string>('npm_package_version', '0.1.0'),
      environment: this.configService.get<string>('NODE_ENV', 'development'),
    };
  }
} 