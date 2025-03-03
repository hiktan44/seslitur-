"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const common_2 = require("@nestjs/common");
async function bootstrap() {
    const logger = new common_2.Logger('Bootstrap');
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.enableCors({
        origin: true,
        methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
        credentials: true,
    });
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
        transformOptions: {
            enableImplicitConversion: true,
        },
    }));
    const config = new swagger_1.DocumentBuilder()
        .setTitle('TurSesli API')
        .setDescription('Grup iletişimi için sesli iletişim API dokümantasyonu')
        .setVersion('1.0')
        .addTag('users', 'Kullanıcı yönetimi')
        .addTag('tours', 'Tur yönetimi')
        .addTag('voice-sessions', 'Sesli oturum yönetimi')
        .addTag('webrtc', 'WebRTC bağlantı yönetimi')
        .addBearerAuth()
        .build();
    const document = swagger_1.SwaggerModule.createDocument(app, config);
    swagger_1.SwaggerModule.setup('api-docs', app, document);
    const port = process.env.PORT || 3000;
    await app.listen(port);
    logger.log(`Uygulama http://localhost:${port} adresinde çalışıyor`);
    logger.log(`API dokümantasyonu http://localhost:${port}/api-docs adresinde erişilebilir`);
}
bootstrap();
//# sourceMappingURL=main.js.map