"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const core_1 = require("@nestjs/core");
const app_controller_1 = require("./app.controller");
const app_service_1 = require("./app.service");
const user_module_1 = require("./modules/user/user.module");
const auth_module_1 = require("./modules/auth/auth.module");
const group_module_1 = require("./modules/group/group.module");
const session_module_1 = require("./modules/session/session.module");
const webrtc_module_1 = require("./modules/webrtc/webrtc.module");
const notification_module_1 = require("./modules/notification/notification.module");
const analytics_module_1 = require("./modules/analytics/analytics.module");
const payment_module_1 = require("./modules/payment/payment.module");
const health_module_1 = require("./modules/health/health.module");
const supabase_module_1 = require("./modules/supabase/supabase.module");
const http_exception_filter_1 = require("./filters/http-exception.filter");
const logging_interceptor_1 = require("./interceptors/logging.interceptor");
let AppModule = class AppModule {
};
AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: ['.env', '.env.local'],
            }),
            typeorm_1.TypeOrmModule.forRootAsync({
                imports: [config_1.ConfigModule],
                inject: [config_1.ConfigService],
                useFactory: (configService) => ({
                    type: 'postgres',
                    host: configService.get('DATABASE_HOST', 'localhost'),
                    port: configService.get('DATABASE_PORT', 5432),
                    username: configService.get('DATABASE_USERNAME', 'postgres'),
                    password: configService.get('DATABASE_PASSWORD', 'postgres'),
                    database: configService.get('DATABASE_NAME', 'sesli_iletisim_db'),
                    entities: [__dirname + '/**/*.entity{.ts,.js}'],
                    synchronize: configService.get('DATABASE_SYNCHRONIZE', true),
                    logging: configService.get('DATABASE_LOGGING', false),
                }),
            }),
            supabase_module_1.SupabaseModule,
            user_module_1.UserModule,
            auth_module_1.AuthModule,
            group_module_1.GroupModule,
            session_module_1.SessionModule,
            webrtc_module_1.WebRtcModule,
            notification_module_1.NotificationModule,
            analytics_module_1.AnalyticsModule,
            payment_module_1.PaymentModule,
            health_module_1.HealthModule,
        ],
        controllers: [app_controller_1.AppController],
        providers: [
            app_service_1.AppService,
            {
                provide: core_1.APP_FILTER,
                useClass: http_exception_filter_1.HttpExceptionFilter,
            },
            {
                provide: core_1.APP_INTERCEPTOR,
                useClass: logging_interceptor_1.LoggingInterceptor,
            },
        ],
    })
], AppModule);
exports.AppModule = AppModule;
//# sourceMappingURL=app.module.js.map