import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { Request, Response } from 'express';

/**
 * Loglama Interceptor'ı
 * 
 * HTTP isteklerini ve yanıtlarını loglayan interceptor
 */
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger(LoggingInterceptor.name);

  /**
   * İsteği ve yanıtı yakalar ve loglar
   * 
   * @param context - Yürütme bağlamı
   * @param next - Çağrı işleyicisi
   * @returns Observable
   */
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const ctx = context.switchToHttp();
    const request = ctx.getRequest<Request>();
    const response = ctx.getResponse<Response>();
    const { method, url, body, ip } = request;
    const userAgent = request.get('user-agent') || '';
    const startTime = Date.now();

    // İsteği logla
    this.logger.log(
      `[${method}] ${url} - IP: ${ip} - User-Agent: ${userAgent}`,
    );

    // İstek gövdesini logla (hassas veriler hariç)
    if (Object.keys(body).length > 0) {
      const sanitizedBody = this.sanitizeBody(body);
      this.logger.debug(`Request Body: ${JSON.stringify(sanitizedBody)}`);
    }

    // Yanıtı logla
    return next.handle().pipe(
      tap({
        next: (data: any) => {
          const endTime = Date.now();
          const duration = endTime - startTime;
          const statusCode = response.statusCode;
          
          this.logger.log(
            `[${method}] ${url} - ${statusCode} - ${duration}ms`,
          );
          
          // Yanıt gövdesini logla (hassas veriler hariç)
          if (data && Object.keys(data).length > 0) {
            const sanitizedData = this.sanitizeBody(data);
            this.logger.debug(`Response Body: ${JSON.stringify(sanitizedData)}`);
          }
        },
        error: (error: any) => {
          const endTime = Date.now();
          const duration = endTime - startTime;
          
          this.logger.error(
            `[${method}] ${url} - Error - ${duration}ms`,
            error.stack,
          );
        },
      }),
    );
  }

  /**
   * Hassas verileri gizler
   * 
   * @param body - İstek veya yanıt gövdesi
   * @returns Temizlenmiş gövde
   */
  private sanitizeBody(body: any): any {
    if (!body) return body;
    
    const sensitiveFields = ['password', 'passwordHash', 'token', 'secret', 'apiKey'];
    const sanitized = { ...body };
    
    for (const field of sensitiveFields) {
      if (field in sanitized) {
        sanitized[field] = '***HIDDEN***';
      }
    }
    
    return sanitized;
  }
} 