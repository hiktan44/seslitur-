import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as helmet from 'helmet';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './filters/http-exception.filter';
import { Logger } from '@nestjs/common';
import * as express from 'express';
import * as cors from 'cors';

/**
 * Ana uygulama başlatma fonksiyonu
 */
async function bootstrap() {
  const app = express();
  const logger = new Logger('Bootstrap');
  
  // CORS ayarları
  app.use(cors());
  
  // JSON parser
  app.use(express.json());
  
  // Mock login endpoint
  app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;
    
    // Test kullanıcıları
    const testUsers = [
      { email: 'test1@example.com', password: 'test123', name: 'Test Kullanıcı 1' },
      { email: 'test2@example.com', password: 'test123', name: 'Test Kullanıcı 2' },
      { email: 'test3@example.com', password: 'test123', name: 'Test Kullanıcı 3' },
      { email: 'test4@example.com', password: 'test123', name: 'Test Kullanıcı 4' },
      { email: 'test5@example.com', password: 'test123', name: 'Test Kullanıcı 5' }
    ];
    
    // Admin kullanıcısı
    if (email === 'admin@example.com' && password === '12345') {
      return res.json({
        token: 'mock-admin-token',
        user: {
          id: 'admin-id',
          email: 'admin@example.com',
          name: 'Admin',
          role: 'admin'
        }
      });
    }
    
    // Test kullanıcı kontrolü
    const user = testUsers.find(u => u.email === email && u.password === password);
    if (user) {
      return res.json({
        token: 'mock-user-token',
        user: {
          id: email,
          email: email,
          name: user.name,
          role: 'user'
        }
      });
    }
    
    // Giriş başarısız
    return res.status(401).json({
      message: 'Geçersiz e-posta veya şifre'
    });
  });
  
  // Sunucuyu başlat
  const port = process.env.PORT || 5000;
  app.listen(port, () => {
    logger.log(`Mock API sunucusu ${port} portunda çalışıyor`);
  });
}

// Uygulamayı başlat
bootstrap().catch(err => {
  console.error('Uygulama başlatılırken hata oluştu:', err);
  process.exit(1);
}); 