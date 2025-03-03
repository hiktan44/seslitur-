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
exports.UpdatePasswordDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class UpdatePasswordDto {
}
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının mevcut parolası',
        example: 'EskiParola123',
    }),
    (0, class_validator_1.IsString)({ message: 'Mevcut parola bir metin olmalıdır' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Mevcut parola zorunludur' }),
    __metadata("design:type", String)
], UpdatePasswordDto.prototype, "currentPassword", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının yeni parolası (en az 8 karakter, büyük/küçük harf ve rakam içermeli)',
        example: 'YeniGuclu.Parola123',
    }),
    (0, class_validator_1.IsString)({ message: 'Yeni parola bir metin olmalıdır' }),
    (0, class_validator_1.MinLength)(8, { message: 'Yeni parola en az 8 karakter olmalıdır' }),
    (0, class_validator_1.MaxLength)(50, { message: 'Yeni parola en fazla 50 karakter olmalıdır' }),
    (0, class_validator_1.Matches)(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
        message: 'Yeni parola en az bir büyük harf, bir küçük harf ve bir rakam içermelidir',
    }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Yeni parola zorunludur' }),
    __metadata("design:type", String)
], UpdatePasswordDto.prototype, "newPassword", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Yeni parolanın tekrarı (yeni parola ile aynı olmalıdır)',
        example: 'YeniGuclu.Parola123',
    }),
    (0, class_validator_1.IsString)({ message: 'Parola tekrarı bir metin olmalıdır' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Parola tekrarı zorunludur' }),
    __metadata("design:type", String)
], UpdatePasswordDto.prototype, "passwordConfirmation", void 0);
exports.UpdatePasswordDto = UpdatePasswordDto;
//# sourceMappingURL=update-password.dto.js.map