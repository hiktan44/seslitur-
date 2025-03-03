"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var LoggingInterceptor_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.LoggingInterceptor = void 0;
const common_1 = require("@nestjs/common");
const operators_1 = require("rxjs/operators");
let LoggingInterceptor = LoggingInterceptor_1 = class LoggingInterceptor {
    constructor() {
        this.logger = new common_1.Logger(LoggingInterceptor_1.name);
    }
    intercept(context, next) {
        const ctx = context.switchToHttp();
        const request = ctx.getRequest();
        const response = ctx.getResponse();
        const { method, url, body, ip } = request;
        const userAgent = request.get('user-agent') || '';
        const startTime = Date.now();
        this.logger.log(`[${method}] ${url} - IP: ${ip} - User-Agent: ${userAgent}`);
        if (Object.keys(body).length > 0) {
            const sanitizedBody = this.sanitizeBody(body);
            this.logger.debug(`Request Body: ${JSON.stringify(sanitizedBody)}`);
        }
        return next.handle().pipe((0, operators_1.tap)({
            next: (data) => {
                const endTime = Date.now();
                const duration = endTime - startTime;
                const statusCode = response.statusCode;
                this.logger.log(`[${method}] ${url} - ${statusCode} - ${duration}ms`);
                if (data && Object.keys(data).length > 0) {
                    const sanitizedData = this.sanitizeBody(data);
                    this.logger.debug(`Response Body: ${JSON.stringify(sanitizedData)}`);
                }
            },
            error: (error) => {
                const endTime = Date.now();
                const duration = endTime - startTime;
                this.logger.error(`[${method}] ${url} - Error - ${duration}ms`, error.stack);
            },
        }));
    }
    sanitizeBody(body) {
        if (!body)
            return body;
        const sensitiveFields = ['password', 'passwordHash', 'token', 'secret', 'apiKey'];
        const sanitized = Object.assign({}, body);
        for (const field of sensitiveFields) {
            if (field in sanitized) {
                sanitized[field] = '***HIDDEN***';
            }
        }
        return sanitized;
    }
};
LoggingInterceptor = LoggingInterceptor_1 = __decorate([
    (0, common_1.Injectable)()
], LoggingInterceptor);
exports.LoggingInterceptor = LoggingInterceptor;
//# sourceMappingURL=logging.interceptor.js.map