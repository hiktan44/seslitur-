import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AppService } from './app.service';

/**
 * Ana Uygulama Kontrolcüsü
 * 
 * Temel uygulama endpoint'lerini içerir
 */
@ApiTags('app')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  /**
   * Kök endpoint
   * 
   * @returns Karşılama mesajı
   */
  @ApiOperation({ summary: 'Kök endpoint' })
  @ApiResponse({
    status: 200,
    description: 'Karşılama mesajı',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string' },
        version: { type: 'string' },
        timestamp: { type: 'string', format: 'date-time' },
      },
    },
  })
  @Get()
  getHello() {
    return this.appService.getHello();
  }

  /**
   * Sağlık kontrolü endpoint'i
   * 
   * @returns Sağlık durumu
   */
  @ApiOperation({ summary: 'Sağlık kontrolü' })
  @ApiResponse({
    status: 200,
    description: 'Uygulama sağlık durumu',
    schema: {
      type: 'object',
      properties: {
        status: { type: 'string' },
        timestamp: { type: 'string', format: 'date-time' },
        uptime: { type: 'number' },
        version: { type: 'string' },
      },
    },
  })
  @Get('health')
  getHealth() {
    return this.appService.getHealth();
  }
} 