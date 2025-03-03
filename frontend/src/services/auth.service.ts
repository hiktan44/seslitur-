import api from './api';
import supabase from './supabase';

/**
 * Kimlik Doğrulama Servisi
 * 
 * Kullanıcı kimlik doğrulama işlemlerini gerçekleştiren servis
 */
export interface LoginCredentials {
  email: string;
  password: string;
  isAdmin?: boolean; // Admin girişi için eklendi
}

export interface RegisterData {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phoneNumber?: string;
  isAdmin?: boolean; // Admin kaydı için eklendi
}

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  roles: string[];
  isAdmin?: boolean; // Admin kontrolü için eklendi
}

export interface AuthResponse {
  accessToken: string;
  user: User;
}

/**
 * Kullanıcı girişi yapar
 * 
 * @param credentials - Giriş bilgileri
 * @returns Kimlik doğrulama yanıtı
 */
export const login = async (credentials: LoginCredentials): Promise<AuthResponse> => {
  try {
    // Admin girişi kontrolü
    if (credentials.isAdmin || credentials.email === 'admin@example.com') {
      // Admin kullanıcısı için şifre kontrolü
      if (credentials.email === 'admin@example.com' && credentials.password !== '12345') {
        throw new Error('Geçersiz admin şifresi. Doğru şifre: 12345');
      }
      
      // Admin kullanıcısı için özel işlem
      const adminUser: User = {
        id: 'admin-id',
        email: credentials.email || 'admin@example.com',
        firstName: 'Admin',
        lastName: 'Kullanıcı',
        roles: ['admin', 'user'],
        isAdmin: true
      };
      
      const adminResponse: AuthResponse = {
        accessToken: 'admin-token',
        user: adminUser
      };
      
      // Token ve kullanıcı bilgilerini localStorage'a kaydet
      localStorage.setItem('accessToken', adminResponse.accessToken);
      localStorage.setItem('user', JSON.stringify(adminResponse.user));
      
      return adminResponse;
    }

    // Normal kullanıcı girişi
    // Supabase ile giriş yap
    const { data: supabaseData, error: supabaseError } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password,
    });

    if (supabaseError) {
      throw new Error(supabaseError.message);
    }

    // Backend API ile token al
    const response = await api.post<AuthResponse>('/auth/login', credentials);
    
    // Token ve kullanıcı bilgilerini localStorage'a kaydet
    localStorage.setItem('accessToken', response.data.accessToken);
    localStorage.setItem('user', JSON.stringify(response.data.user));
    
    return response.data;
  } catch (error) {
    console.error('Giriş hatası:', error);
    throw error;
  }
};

/**
 * Kullanıcı kaydı yapar
 * 
 * @param data - Kayıt bilgileri
 * @returns Kimlik doğrulama yanıtı
 */
export const register = async (data: RegisterData): Promise<AuthResponse> => {
  try {
    // Admin kaydı kontrolü
    if (data.isAdmin || data.email === 'admin@example.com') {
      // Admin şifresi kontrolü - sadece uzunluk kontrolü yap
      if (data.password.length < 5) {
        throw new Error('Şifre en az 5 karakter olmalıdır.');
      }
      
      // Admin e-postası için kontrol
      if (data.email === 'admin@example.com' && data.password !== '12345') {
        throw new Error('Admin hesabı için şifre 12345 olmalıdır.');
      }
      
      // Admin kullanıcısı için özel işlem
      const adminUser: User = {
        id: 'admin-id',
        email: data.email || 'admin@example.com',
        firstName: data.firstName || 'Admin',
        lastName: data.lastName || 'Kullanıcı',
        roles: ['admin', 'user'],
        isAdmin: true
      };
      
      const adminResponse: AuthResponse = {
        accessToken: 'admin-token',
        user: adminUser
      };
      
      // Token ve kullanıcı bilgilerini localStorage'a kaydet
      localStorage.setItem('accessToken', adminResponse.accessToken);
      localStorage.setItem('user', JSON.stringify(adminResponse.user));
      
      return adminResponse;
    }

    // Normal kullanıcı kaydı
    // Backend API ile kayıt ol
    const response = await api.post<AuthResponse>('/auth/register', data);
    
    // Token ve kullanıcı bilgilerini localStorage'a kaydet
    localStorage.setItem('accessToken', response.data.accessToken);
    localStorage.setItem('user', JSON.stringify(response.data.user));
    
    return response.data;
  } catch (error) {
    console.error('Kayıt hatası:', error);
    throw error;
  }
};

/**
 * Kullanıcı çıkışı yapar
 */
export const logout = async (): Promise<void> => {
  try {
    // Supabase ile çıkış yap
    await supabase.auth.signOut();
    
    // Backend API ile çıkış yap
    await api.post('/auth/logout');
    
    // LocalStorage'dan token ve kullanıcı bilgilerini temizle
    localStorage.removeItem('accessToken');
    localStorage.removeItem('user');
  } catch (error) {
    console.error('Çıkış hatası:', error);
    
    // Hata olsa bile localStorage'ı temizle
    localStorage.removeItem('accessToken');
    localStorage.removeItem('user');
  }
};

/**
 * Mevcut kullanıcıyı getirir
 * 
 * @returns Mevcut kullanıcı veya null
 */
export const getCurrentUser = (): User | null => {
  const userJson = localStorage.getItem('user');
  
  if (userJson) {
    try {
      return JSON.parse(userJson) as User;
    } catch (error) {
      console.error('Kullanıcı bilgisi ayrıştırma hatası:', error);
      return null;
    }
  }
  
  return null;
};

/**
 * Kullanıcının oturum açıp açmadığını kontrol eder
 * 
 * @returns Oturum açık mı
 */
export const isAuthenticated = (): boolean => {
  return !!localStorage.getItem('accessToken');
};

/**
 * Parola sıfırlama e-postası gönderir
 * 
 * @param email - Kullanıcı e-posta adresi
 */
export const forgotPassword = async (email: string): Promise<void> => {
  try {
    // Supabase ile parola sıfırlama e-postası gönder
    const { error } = await supabase.auth.resetPasswordForEmail(email);
    
    if (error) {
      throw new Error(error.message);
    }
    
    // Backend API ile parola sıfırlama e-postası gönder
    await api.post('/auth/forgot-password', { email });
  } catch (error) {
    console.error('Parola sıfırlama hatası:', error);
    throw error;
  }
};

/**
 * Parolayı sıfırlar
 * 
 * @param token - Sıfırlama token'ı
 * @param newPassword - Yeni parola
 */
export const resetPassword = async (token: string, newPassword: string): Promise<void> => {
  try {
    // Backend API ile parolayı sıfırla
    await api.post('/auth/reset-password', { token, newPassword });
  } catch (error) {
    console.error('Parola sıfırlama hatası:', error);
    throw error;
  }
}; 