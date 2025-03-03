import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import * as authService from '../services/auth.service';
import { User, LoginCredentials, RegisterData } from '../services/auth.service';

/**
 * Kimlik Doğrulama Bağlamı
 * 
 * Kullanıcı kimlik doğrulama durumunu ve işlevlerini sağlayan bağlam
 */
interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => Promise<void>;
  forgotPassword: (email: string) => Promise<void>;
  resetPassword: (token: string, newPassword: string) => Promise<void>;
  setUser: (user: User) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const navigate = useNavigate();

  // Sayfa yüklendiğinde kullanıcı durumunu kontrol et
  useEffect(() => {
    const checkAuthStatus = async () => {
      try {
        const currentUser = authService.getCurrentUser();
        
        if (currentUser) {
          setUser(currentUser);
        }
      } catch (error) {
        console.error('Kimlik doğrulama durumu kontrolü hatası:', error);
        // Hata durumunda localStorage'ı temizle
        localStorage.removeItem('accessToken');
        localStorage.removeItem('user');
      } finally {
        setIsLoading(false);
      }
    };

    checkAuthStatus();
  }, []);

  /**
   * Kullanıcı girişi yapar
   * 
   * @param credentials - Giriş bilgileri
   */
  const login = async (credentials: LoginCredentials): Promise<void> => {
    setIsLoading(true);
    
    try {
      const response = await authService.login(credentials);
      setUser(response.user);
      toast.success('Giriş başarılı!');
      navigate('/dashboard');
    } catch (error: any) {
      console.error('Giriş hatası:', error);
      toast.error(error.response?.data?.message || 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Kullanıcı kaydı yapar
   * 
   * @param data - Kayıt bilgileri
   */
  const register = async (data: RegisterData): Promise<void> => {
    setIsLoading(true);
    
    try {
      const response = await authService.register(data);
      setUser(response.user);
      toast.success('Kayıt başarılı!');
      navigate('/dashboard');
    } catch (error: any) {
      console.error('Kayıt hatası:', error);
      toast.error(error.response?.data?.message || 'Kayıt başarısız. Lütfen bilgilerinizi kontrol edin.');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Kullanıcı çıkışı yapar
   */
  const logout = async (): Promise<void> => {
    setIsLoading(true);
    
    try {
      await authService.logout();
      setUser(null);
      toast.success('Çıkış başarılı!');
      navigate('/login');
    } catch (error) {
      console.error('Çıkış hatası:', error);
      // Hata olsa bile kullanıcıyı çıkış yapmış olarak işaretle
      setUser(null);
      navigate('/login');
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Parola sıfırlama e-postası gönderir
   * 
   * @param email - Kullanıcı e-posta adresi
   */
  const forgotPassword = async (email: string): Promise<void> => {
    setIsLoading(true);
    
    try {
      await authService.forgotPassword(email);
      toast.success('Parola sıfırlama bağlantısı e-posta adresinize gönderildi.');
    } catch (error: any) {
      console.error('Parola sıfırlama hatası:', error);
      toast.error(error.response?.data?.message || 'Parola sıfırlama başarısız. Lütfen daha sonra tekrar deneyin.');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Parolayı sıfırlar
   * 
   * @param token - Sıfırlama token'ı
   * @param newPassword - Yeni parola
   */
  const resetPassword = async (token: string, newPassword: string): Promise<void> => {
    setIsLoading(true);
    
    try {
      await authService.resetPassword(token, newPassword);
      toast.success('Parolanız başarıyla sıfırlandı. Lütfen yeni parolanızla giriş yapın.');
      navigate('/login');
    } catch (error: any) {
      console.error('Parola sıfırlama hatası:', error);
      toast.error(error.response?.data?.message || 'Parola sıfırlama başarısız. Lütfen daha sonra tekrar deneyin.');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    register,
    logout,
    forgotPassword,
    resetPassword,
    setUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

/**
 * Kimlik doğrulama bağlamını kullanmak için hook
 * 
 * @returns Kimlik doğrulama bağlamı
 */
export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  
  if (context === undefined) {
    throw new Error('useAuth hook must be used within an AuthProvider');
  }
  
  return context;
}; 