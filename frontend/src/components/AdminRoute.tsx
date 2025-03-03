import React from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { isAdmin } from '../utils/auth.utils';

/**
 * Admin Koruyucu Bileşeni
 * 
 * Sadece admin yetkisine sahip kullanıcıların erişebileceği rotaları korur.
 * Admin olmayan kullanıcıları giriş sayfasına yönlendirir.
 */
const AdminRoute: React.FC = () => {
  const { user } = useAuth();
  const location = useLocation();
  
  // Kullanıcı admin değilse giriş sayfasına yönlendir
  if (!isAdmin(user)) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }
  
  // Kullanıcı admin ise alt bileşenleri göster
  return <Outlet />;
};

export default AdminRoute; 