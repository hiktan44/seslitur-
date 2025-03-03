import axios from 'axios';

/**
 * API Servisi
 * 
 * Backend API ile iletişim kurmak için kullanılan servis
 */
const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

// Axios istemcisi oluştur
const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// İstek interceptor'ı
api.interceptors.request.use(
  (config) => {
    // LocalStorage'dan token al
    const token = localStorage.getItem('accessToken');
    
    // Token varsa, Authorization header'ına ekle
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Yanıt interceptor'ı
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // 401 Unauthorized hatası durumunda kullanıcıyı çıkış yap
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);

export default api; 