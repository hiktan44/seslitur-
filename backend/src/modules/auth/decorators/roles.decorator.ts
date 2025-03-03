import { SetMetadata } from '@nestjs/common';
import { Role } from '../../../interfaces/role.enum';

/**
 * Roller için metadata anahtarı
 */
export const ROLES_KEY = 'roles';

/**
 * Roller Decorator'ı
 * 
 * Endpoint'lere rol tabanlı erişim kontrolü eklemek için kullanılır
 * 
 * @param roles - İzin verilen roller
 * @returns Decorator
 * 
 * @example
 * ```typescript
 * @Roles(Role.ADMIN, Role.SUPER_ADMIN)
 * @Get('admin-only')
 * getAdminData() {
 *   return 'Bu veriyi sadece adminler görebilir';
 * }
 * ```
 */
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles); 