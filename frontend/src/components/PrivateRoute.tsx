import React from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

/**
 * Özel Rota Bileşeni
 * 
 * Sadece kimlik doğrulaması yapılmış kullanıcıların erişebileceği rotaları korur.
 * Kimlik doğrulaması yapılmamış kullanıcıları giriş sayfasına yönlendirir.
 */
const PrivateRoute: React.FC = () => {
  const { user, isLoading } = useAuth();
  const location = useLocation();
  
  // Yükleniyor durumunda boş içerik göster
  if (isLoading) {
    return <div>Yükleniyor...</div>;
  }
  
  // Kullanıcı oturum açmamışsa giriş sayfasına yönlendir
  if (!user) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }
  
  // Kullanıcı oturum açmışsa alt bileşenleri göster
  return <Outlet />;
};

export default PrivateRoute; 