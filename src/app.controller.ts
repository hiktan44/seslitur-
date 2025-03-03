import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

/**
 * Ana uygulama kontrolörü
 * Basit durum kontrolü için kullanılır
 */
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  /**
   * Basit durum kontrolü için endpoint
   * @returns Uygulama durum mesajı
   */
  @Get()
  getHello(): string {
    return this.appService.getHello();
  }
} 