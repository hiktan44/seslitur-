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
exports.LoginResponseDto = exports.UserInfoDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const role_enum_1 = require("../../../interfaces/role.enum");
class UserInfoDto {
}
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcı ID\'si',
        example: '550e8400-e29b-41d4-a716-446655440000',
    }),
    __metadata("design:type", String)
], UserInfoDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının e-posta adresi',
        example: 'kullanici@example.com',
    }),
    __metadata("design:type", String)
], UserInfoDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının adı',
        example: 'Ahmet',
    }),
    __metadata("design:type", String)
], UserInfoDto.prototype, "firstName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının soyadı',
        example: 'Yılmaz',
    }),
    __metadata("design:type", String)
], UserInfoDto.prototype, "lastName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcının rolleri',
        example: ['user'],
        enum: role_enum_1.Role,
        isArray: true,
    }),
    __metadata("design:type", Array)
], UserInfoDto.prototype, "roles", void 0);
exports.UserInfoDto = UserInfoDto;
class LoginResponseDto {
}
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'JWT erişim token\'ı',
        example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    }),
    __metadata("design:type", String)
], LoginResponseDto.prototype, "accessToken", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Kullanıcı bilgileri',
        type: UserInfoDto,
    }),
    __metadata("design:type", UserInfoDto)
], LoginResponseDto.prototype, "user", void 0);
exports.LoginResponseDto = LoginResponseDto;
//# sourceMappingURL=login-response.dto.js.map