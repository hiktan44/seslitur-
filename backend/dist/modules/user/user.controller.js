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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const user_service_1 = require("./user.service");
const create_user_dto_1 = require("./dto/create-user.dto");
const update_user_dto_1 = require("./dto/update-user.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const roles_guard_1 = require("../auth/guards/roles.guard");
const roles_decorator_1 = require("../auth/decorators/roles.decorator");
const role_enum_1 = require("../../interfaces/role.enum");
const user_status_enum_1 = require("../../interfaces/user-status.enum");
const update_password_dto_1 = require("./dto/update-password.dto");
let UserController = class UserController {
    constructor(userService) {
        this.userService = userService;
    }
    create(createUserDto) {
        return this.userService.create(createUserDto);
    }
    findAll() {
        return this.userService.findAll();
    }
    findMe() {
        return { message: 'Mevcut kullanıcı bilgileri' };
    }
    findOne(id) {
        return this.userService.findById(id);
    }
    update(id, updateUserDto) {
        return this.userService.update(id, updateUserDto);
    }
    updatePassword(id, updatePasswordDto) {
        return this.userService.updatePassword(id, updatePasswordDto.newPassword);
    }
    updateStatus(id, status) {
        return this.userService.updateStatus(id, status);
    }
    remove(id) {
        return this.userService.remove(id);
    }
};
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Yeni bir kullanıcı oluşturur' }),
    (0, swagger_1.ApiResponse)({
        status: 201,
        description: 'Kullanıcı başarıyla oluşturuldu',
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: 'Geçersiz veri',
    }),
    (0, swagger_1.ApiResponse)({
        status: 409,
        description: 'E-posta adresi zaten kullanılıyor',
    }),
    (0, common_1.Post)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.CREATED),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_user_dto_1.CreateUserDto]),
    __metadata("design:returntype", void 0)
], UserController.prototype, "create", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Tüm kullanıcıları getirir' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Kullanıcı listesi başarıyla getirildi',
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Yetkisiz erişim',
    }),
    (0, swagger_1.ApiResponse)({
        status: 403,
        description: 'Erişim reddedildi',
    }),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(role_enum_1.Role.ADMIN, role_enum_1.Role.SUPER_ADMIN),
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], UserController.prototype, "findAll", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Mevcut kullanıcının bilgilerini getirir' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Kullanıcı bilgileri başarıyla getirildi',
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Yetkisiz erişim',
    }),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Get)('me'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], UserController.prototype, "findMe", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'ID\'ye göre kullanıcı getirir' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Kullanıcı ID\'si' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Kullanıcı başarıyla getirildi',
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Yetkisiz erişim',
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Kullanıcı bulunamadı',
    }),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], UserController.prototype, "findOne", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Kullanıcı bilgilerini günceller' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Kullanıcı ID\'si' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Kullanıcı başarıyla güncellendi',
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: 'Geçersiz veri',
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Yetkisiz erişim',
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Kullanıcı bulunamadı',
    }),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_user_dto_1.UpdateUserDto]),
    __metadata("design:returntype", void 0)
], UserController.prototype, "update", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Kullanıcı parolasını günceller' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Kullanıcı ID\'si' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Parola başarıyla güncellendi',
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: 'Geçersiz veri',
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Yetkisiz erişim',
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Kullanıcı bulunamadı',
    }),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Patch)(':id/password'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_password_dto_1.UpdatePasswordDto]),
    __metadata("design:returntype", void 0)
], UserController.prototype, "updatePassword", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Kullanıcı durumunu günceller' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Kullanıcı ID\'si' }),
    (0, swagger_1.ApiQuery)({
        name: 'status',
        enum: user_status_enum_1.UserStatus,
        description: 'Yeni kullanıcı durumu',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Kullanıcı durumu başarıyla güncellendi',
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Yetkisiz erişim',
    }),
    (0, swagger_1.ApiResponse)({
        status: 403,
        description: 'Erişim reddedildi',
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Kullanıcı bulunamadı',
    }),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(role_enum_1.Role.ADMIN, role_enum_1.Role.SUPER_ADMIN),
    (0, common_1.Patch)(':id/status'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], UserController.prototype, "updateStatus", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Kullanıcıyı siler' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Kullanıcı ID\'si' }),
    (0, swagger_1.ApiResponse)({
        status: 204,
        description: 'Kullanıcı başarıyla silindi',
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Yetkisiz erişim',
    }),
    (0, swagger_1.ApiResponse)({
        status: 403,
        description: 'Erişim reddedildi',
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Kullanıcı bulunamadı',
    }),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(role_enum_1.Role.ADMIN, role_enum_1.Role.SUPER_ADMIN),
    (0, common_1.Delete)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.NO_CONTENT),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], UserController.prototype, "remove", null);
UserController = __decorate([
    (0, swagger_1.ApiTags)('users'),
    (0, common_1.Controller)('users'),
    __metadata("design:paramtypes", [user_service_1.UserService])
], UserController);
exports.UserController = UserController;
//# sourceMappingURL=user.controller.js.map