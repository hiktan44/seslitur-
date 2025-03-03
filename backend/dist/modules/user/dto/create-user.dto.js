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
exports.CreateUserDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class CreateUserDto {
}
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının e-posta adresi',
        example: 'kullanici@example.com',
    }),
    (0, class_validator_1.IsEmail)({}, { message: 'Geçerli bir e-posta adresi giriniz' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'E-posta adresi zorunludur' }),
    __metadata("design:type", String)
], CreateUserDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının parolası (en az 8 karakter, büyük/küçük harf ve rakam içermeli)',
        example: 'Guclu.Parola123',
    }),
    (0, class_validator_1.IsString)({ message: 'Parola bir metin olmalıdır' }),
    (0, class_validator_1.MinLength)(8, { message: 'Parola en az 8 karakter olmalıdır' }),
    (0, class_validator_1.MaxLength)(50, { message: 'Parola en fazla 50 karakter olmalıdır' }),
    (0, class_validator_1.Matches)(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
        message: 'Parola en az bir büyük harf, bir küçük harf ve bir rakam içermelidir',
    }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Parola zorunludur' }),
    __metadata("design:type", String)
], CreateUserDto.prototype, "password", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının adı',
        example: 'Ahmet',
    }),
    (0, class_validator_1.IsString)({ message: 'Ad bir metin olmalıdır' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Ad zorunludur' }),
    (0, class_validator_1.MinLength)(2, { message: 'Ad en az 2 karakter olmalıdır' }),
    (0, class_validator_1.MaxLength)(50, { message: 'Ad en fazla 50 karakter olmalıdır' }),
    __metadata("design:type", String)
], CreateUserDto.prototype, "firstName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının soyadı',
        example: 'Yılmaz',
    }),
    (0, class_validator_1.IsString)({ message: 'Soyad bir metin olmalıdır' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Soyad zorunludur' }),
    (0, class_validator_1.MinLength)(2, { message: 'Soyad en az 2 karakter olmalıdır' }),
    (0, class_validator_1.MaxLength)(50, { message: 'Soyad en fazla 50 karakter olmalıdır' }),
    __metadata("design:type", String)
], CreateUserDto.prototype, "lastName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının telefon numarası',
        example: '+905551234567',
        required: false,
    }),
    (0, class_validator_1.IsString)({ message: 'Telefon numarası bir metin olmalıdır' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateUserDto.prototype, "phoneNumber", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının profil resmi URL\'si',
        example: 'https://example.com/profile.jpg',
        required: false,
    }),
    (0, class_validator_1.IsString)({ message: 'Profil resmi URL\'si bir metin olmalıdır' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateUserDto.prototype, "profilePicture", void 0);
exports.CreateUserDto = CreateUserDto;
//# sourceMappingURL=create-user.dto.js.map