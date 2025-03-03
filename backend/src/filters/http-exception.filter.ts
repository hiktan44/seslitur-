import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

/**
 * HTTP İstisna Filtresi
 * 
 * HTTP istisnaları için özel yanıt formatı sağlayan filtre
 */
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  /**
   * İstisnayı yakalar ve özel yanıt formatı oluşturur
   * 
   * @param exception - Yakalanan HTTP istisnası
   * @param host - Argüman host'u
   */
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const status = exception.getStatus();
    const errorResponse = exception.getResponse();

    // İstisnayı logla
    this.logger.error(
      `${request.method} ${request.url} - ${status} - ${JSON.stringify(errorResponse)}`,
      exception.stack,
    );

    // Yanıt formatını oluştur
    const responseBody = {
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      method: request.method,
      error: typeof errorResponse === 'object' 
        ? errorResponse 
        : { message: errorResponse },
    };

    // Yanıtı gönder
    response.status(status).json(responseBody);
  }
}

/**
 * Tüm İstisnalar Filtresi
 * 
 * Tüm istisnaları yakalayan ve HTTP yanıtına dönüştüren filtre
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  /**
   * İstisnayı yakalar ve HTTP yanıtına dönüştürür
   * 
   * @param exception - Yakalanan istisna
   * @param host - Argüman host'u
   */
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    
    // HTTP istisnası ise status kodunu al, değilse 500 kullan
    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    // İstisnayı logla
    this.logger.error(
      `${request.method} ${request.url} - ${status}`,
      exception instanceof Error ? exception.stack : String(exception),
    );

    // Yanıt formatını oluştur
    const responseBody = {
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      method: request.method,
      error: {
        message: exception instanceof Error 
          ? exception.message 
          : 'Beklenmeyen bir hata oluştu',
      },
    };

    // Yanıtı gönder
    response.status(status).json(responseBody);
  }
} 