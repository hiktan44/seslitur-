import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);
  
  // CORS yapılandırması
  app.enableCors({
    origin: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });
  
  // Validasyon pipe'ını global olarak ekle
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    transform: true,
    forbidNonWhitelisted: true,
    transformOptions: {
      enableImplicitConversion: true,
    },
  }));
  
  // Swagger API dokümantasyonu
  const config = new DocumentBuilder()
    .setTitle('TurSesli API')
    .setDescription('Grup iletişimi için sesli iletişim API dokümantasyonu')
    .setVersion('1.0')
    .addTag('users', 'Kullanıcı yönetimi')
    .addTag('tours', 'Tur yönetimi')
    .addTag('voice-sessions', 'Sesli oturum yönetimi')
    .addTag('webrtc', 'WebRTC bağlantı yönetimi')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);
  
  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`Uygulama http://localhost:${port} adresinde çalışıyor`);
  logger.log(`API dokümantasyonu http://localhost:${port}/api-docs adresinde erişilebilir`);
}
bootstrap(); 