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
exports.SupabaseUserService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("./supabase.service");
const user_entity_1 = require("../../entities/user.entity");
const user_status_enum_1 = require("../../interfaces/user-status.enum");
const role_enum_1 = require("../../interfaces/role.enum");
let SupabaseUserService = class SupabaseUserService {
    constructor(supabaseService) {
        this.supabaseService = supabaseService;
    }
    async create(createUserDto) {
        const { data: authData, error: authError } = await this.supabaseService.getAuth().signUp({
            email: createUserDto.email,
            password: createUserDto.password,
        });
        if (authError) {
            throw new Error(`Supabase Auth hatası: ${authError.message}`);
        }
        const { data: userData, error: userError } = await this.supabaseService.from('users').insert({
            id: authData.user.id,
            email: createUserDto.email,
            first_name: createUserDto.firstName,
            last_name: createUserDto.lastName,
            phone_number: createUserDto.phoneNumber,
            profile_picture: createUserDto.profilePicture,
            status: user_status_enum_1.UserStatus.ACTIVE,
            roles: [role_enum_1.Role.USER],
        }).select().single();
        if (userError) {
            throw new Error(`Supabase DB hatası: ${userError.message}`);
        }
        return this.mapToUserEntity(userData);
    }
    async findAll() {
        const { data, error } = await this.supabaseService.from('users').select('*');
        if (error) {
            throw new Error(`Supabase hatası: ${error.message}`);
        }
        return data.map(user => this.mapToUserEntity(user));
    }
    async findById(id) {
        const { data, error } = await this.supabaseService.from('users')
            .select('*')
            .eq('id', id)
            .single();
        if (error) {
            throw new Error(`Supabase hatası: ${error.message}`);
        }
        return this.mapToUserEntity(data);
    }
    async findByEmail(email) {
        const { data, error } = await this.supabaseService.from('users')
            .select('*')
            .eq('email', email)
            .single();
        if (error) {
            if (error.code === 'PGRST116') {
                return null;
            }
            throw new Error(`Supabase hatası: ${error.message}`);
        }
        return this.mapToUserEntity(data);
    }
    async update(id, updateUserDto) {
        const updateData = Object.assign(Object.assign(Object.assign(Object.assign(Object.assign(Object.assign(Object.assign({}, (updateUserDto.firstName && { first_name: updateUserDto.firstName })), (updateUserDto.lastName && { last_name: updateUserDto.lastName })), (updateUserDto.phoneNumber && { phone_number: updateUserDto.phoneNumber })), (updateUserDto.profilePicture && { profile_picture: updateUserDto.profilePicture })), (updateUserDto.language && { language: updateUserDto.language })), (updateUserDto.timezone && { timezone: updateUserDto.timezone })), { updated_at: new Date() });
        const { data, error } = await this.supabaseService.from('users')
            .update(updateData)
            .eq('id', id)
            .select()
            .single();
        if (error) {
            throw new Error(`Supabase hatası: ${error.message}`);
        }
        return this.mapToUserEntity(data);
    }
    async updatePassword(id, newPassword) {
        const user = await this.findById(id);
        const { error } = await this.supabaseService.getAuth().updateUser({
            password: newPassword,
        });
        if (error) {
            throw new Error(`Supabase Auth hatası: ${error.message}`);
        }
    }
    async updateStatus(id, status) {
        const { data, error } = await this.supabaseService.from('users')
            .update({ status, updated_at: new Date() })
            .eq('id', id)
            .select()
            .single();
        if (error) {
            throw new Error(`Supabase hatası: ${error.message}`);
        }
        return this.mapToUserEntity(data);
    }
    async remove(id) {
        const { error: authError } = await this.supabaseService.getAuth().admin.deleteUser(id);
        if (authError) {
            throw new Error(`Supabase Auth hatası: ${authError.message}`);
        }
        const { error: dbError } = await this.supabaseService.from('users')
            .delete()
            .eq('id', id);
        if (dbError) {
            throw new Error(`Supabase DB hatası: ${dbError.message}`);
        }
    }
    async updateLastLogin(id) {
        const { data, error } = await this.supabaseService.from('users')
            .update({ last_login_at: new Date(), updated_at: new Date() })
            .eq('id', id)
            .select()
            .single();
        if (error) {
            throw new Error(`Supabase hatası: ${error.message}`);
        }
        return this.mapToUserEntity(data);
    }
    mapToUserEntity(data) {
        const user = new user_entity_1.User();
        user.id = data.id;
        user.email = data.email;
        user.firstName = data.first_name;
        user.lastName = data.last_name;
        user.phoneNumber = data.phone_number;
        user.profilePicture = data.profile_picture;
        user.status = data.status;
        user.roles = data.roles;
        user.language = data.language;
        user.timezone = data.timezone;
        user.lastLoginAt = data.last_login_at;
        user.createdAt = data.created_at;
        user.updatedAt = data.updated_at;
        return user;
    }
};
SupabaseUserService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], SupabaseUserService);
exports.SupabaseUserService = SupabaseUserService;
//# sourceMappingURL=supabase-user.service.js.map