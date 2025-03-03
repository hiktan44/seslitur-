"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const swagger_1 = require("@nestjs/swagger");
const helmet = require("helmet");
const app_module_1 = require("./app.module");
const http_exception_filter_1 = require("./filters/http-exception.filter");
const common_2 = require("@nestjs/common");
async function bootstrap() {
    const logger = new common_2.Logger('Bootstrap');
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    const configService = app.get(config_1.ConfigService);
    const apiPrefix = configService.get('API_PREFIX', 'api');
    app.setGlobalPrefix(apiPrefix);
    const corsOrigins = configService.get('CORS_ORIGIN', 'http://localhost:3000')
        .split(',')
        .map(origin => origin.trim());
    app.enableCors({
        origin: corsOrigins,
        methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
        credentials: true,
    });
    app.use(helmet());
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
        transformOptions: {
            enableImplicitConversion: true,
        },
    }));
    app.useGlobalFilters(new http_exception_filter_1.AllExceptionsFilter());
    const options = new swagger_1.DocumentBuilder()
        .setTitle('Sesli İletişim Sistemi API')
        .setDescription('Gerçek zamanlı internet tabanlı sesli iletişim sistemi API dokümantasyonu')
        .setVersion('1.0')
        .addBearerAuth()
        .build();
    const document = swagger_1.SwaggerModule.createDocument(app, options);
    swagger_1.SwaggerModule.setup(`${apiPrefix}/docs`, app, document);
    const port = configService.get('PORT', 5000);
    await app.listen(port);
    logger.log(`Uygulama http://localhost:${port}/${apiPrefix} adresinde çalışıyor`);
    logger.log(`Swagger dokümantasyonu http://localhost:${port}/${apiPrefix}/docs adresinde`);
}
bootstrap().catch(err => {
    console.error('Uygulama başlatılırken hata oluştu:', err);
    process.exit(1);
});
//# sourceMappingURL=main.js.map