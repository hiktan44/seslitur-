import { User } from '../services/auth.service';

/**
 * Kullanıcının belirli bir role sahip olup olmadığını kontrol eder
 * 
 * @param user - Kullanıcı nesnesi
 * @param role - Kontrol edilecek rol
 * @returns Kullanıcının role sahip olup olmadığı
 */
export const hasRole = (user: User | null, role: string): boolean => {
  if (!user) return false;
  return user.roles.includes(role);
};

/**
 * Kullanıcının admin olup olmadığını kontrol eder
 * 
 * @param user - Kullanıcı nesnesi
 * @returns Kullanıcının admin olup olmadığı
 */
export const isAdmin = (user: User | null): boolean => {
  if (!user) return false;
  return user.isAdmin === true || hasRole(user, 'admin');
};

/**
 * Kullanıcının belirli bir kaynağa erişim yetkisi olup olmadığını kontrol eder
 * 
 * @param user - Kullanıcı nesnesi
 * @param resourceOwnerId - Kaynağın sahibinin ID'si
 * @returns Kullanıcının kaynağa erişim yetkisi olup olmadığı
 */
export const canAccessResource = (user: User | null, resourceOwnerId: string): boolean => {
  if (!user) return false;
  if (isAdmin(user)) return true;
  return user.id === resourceOwnerId;
};

/**
 * Kullanıcının oturum açmış olup olmadığını kontrol eder
 * 
 * @returns Kullanıcının oturum açmış olup olmadığı
 */
export const isAuthenticated = (): boolean => {
  const token = localStorage.getItem('accessToken');
  const user = localStorage.getItem('user');
  return !!token && !!user;
};

/**
 * Kullanıcının oturum bilgilerini localStorage'dan alır
 * 
 * @returns Kullanıcı nesnesi veya null
 */
export const getAuthenticatedUser = (): User | null => {
  const userStr = localStorage.getItem('user');
  if (!userStr) return null;
  
  try {
    return JSON.parse(userStr) as User;
  } catch (error) {
    console.error('Kullanıcı bilgileri çözümlenemedi:', error);
    return null;
  }
};

/**
 * Kullanıcının oturum bilgilerini localStorage'a kaydeder
 * 
 * @param user - Kullanıcı nesnesi
 * @param token - Erişim token'ı
 */
export const setAuthenticatedUser = (user: User, token: string): void => {
  localStorage.setItem('user', JSON.stringify(user));
  localStorage.setItem('accessToken', token);
};

/**
 * Kullanıcının oturum bilgilerini localStorage'dan temizler
 */
export const clearAuthenticatedUser = (): void => {
  localStorage.removeItem('user');
  localStorage.removeItem('accessToken');
}; 