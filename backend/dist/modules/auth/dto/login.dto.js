"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LoginDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class LoginDto {
}
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının e-posta adresi',
        example: 'kullanici@example.com',
    }),
    (0, class_validator_1.IsEmail)({}, { message: 'Geçerli bir e-posta adresi giriniz' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'E-posta adresi zorunludur' }),
    __metadata("design:type", String)
], LoginDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının parolası',
        example: 'Guclu.Parola123',
    }),
    (0, class_validator_1.IsString)({ message: 'Parola bir metin olmalıdır' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Parola zorunludur' }),
    __metadata("design:type", String)
], LoginDto.prototype, "password", void 0);
exports.LoginDto = LoginDto;
//# sourceMappingURL=login.dto.js.map