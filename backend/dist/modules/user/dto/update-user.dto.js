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
exports.UpdateUserDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const mapped_types_1 = require("@nestjs/mapped-types");
const create_user_dto_1 = require("./create-user.dto");
class UpdateUserDto extends (0, mapped_types_1.PartialType)(create_user_dto_1.CreateUserDto) {
}
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının adı',
        example: 'Ahmet',
        required: false,
    }),
    (0, class_validator_1.IsString)({ message: 'Ad bir metin olmalıdır' }),
    (0, class_validator_1.MinLength)(2, { message: 'Ad en az 2 karakter olmalıdır' }),
    (0, class_validator_1.MaxLength)(50, { message: 'Ad en fazla 50 karakter olmalıdır' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateUserDto.prototype, "firstName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının soyadı',
        example: 'Yılmaz',
        required: false,
    }),
    (0, class_validator_1.IsString)({ message: 'Soyad bir metin olmalıdır' }),
    (0, class_validator_1.MinLength)(2, { message: 'Soyad en az 2 karakter olmalıdır' }),
    (0, class_validator_1.MaxLength)(50, { message: 'Soyad en fazla 50 karakter olmalıdır' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateUserDto.prototype, "lastName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının telefon numarası',
        example: '+905551234567',
        required: false,
    }),
    (0, class_validator_1.IsString)({ message: 'Telefon numarası bir metin olmalıdır' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateUserDto.prototype, "phoneNumber", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının profil resmi URL\'si',
        example: 'https://example.com/profile.jpg',
        required: false,
    }),
    (0, class_validator_1.IsString)({ message: 'Profil resmi URL\'si bir metin olmalıdır' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateUserDto.prototype, "profilePicture", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının tercih ettiği dil',
        example: 'tr',
        required: false,
    }),
    (0, class_validator_1.IsString)({ message: 'Dil bir metin olmalıdır' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateUserDto.prototype, "language", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının zaman dilimi',
        example: 'Europe/Istanbul',
        required: false,
    }),
    (0, class_validator_1.IsString)({ message: 'Zaman dilimi bir metin olmalıdır' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateUserDto.prototype, "timezone", void 0);
exports.UpdateUserDto = UpdateUserDto;
//# sourceMappingURL=update-user.dto.js.map