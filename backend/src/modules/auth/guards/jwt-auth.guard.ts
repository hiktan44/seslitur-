import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * JWT Kimlik Doğrulama Guard'ı
 * 
 * JWT token ile korunan route'lar için kimlik doğrulama guard'ı
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {} 