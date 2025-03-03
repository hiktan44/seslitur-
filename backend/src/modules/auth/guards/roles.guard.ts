import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '../../../interfaces/role.enum';
import { ROLES_KEY } from '../decorators/roles.decorator';

/**
 * Rol Tabanlı Yetkilendirme Guard'ı
 * 
 * Kullanıcının belirli bir endpoint'e erişim için gerekli rollere sahip olup olmadığını kontrol eder
 */
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  /**
   * Kullanıcının erişim yetkisini kontrol eder
   * 
   * @param context - Yürütme bağlamı
   * @returns Erişim izni varsa true, yoksa false
   */
  canActivate(context: ExecutionContext): boolean {
    // Endpoint için gerekli rolleri al
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    
    // Rol kontrolü yoksa erişime izin ver
    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }
    
    // İstek nesnesinden kullanıcıyı al
    const { user } = context.switchToHttp().getRequest();
    
    // Kullanıcı yoksa erişimi reddet
    if (!user) {
      return false;
    }
    
    // Kullanıcının rollerini kontrol et
    return requiredRoles.some((role) => user.roles?.includes(role));
  }
} 