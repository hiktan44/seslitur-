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
exports.SupabaseAuthService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("./supabase.service");
const supabase_user_service_1 = require("./supabase-user.service");
let SupabaseAuthService = class SupabaseAuthService {
    constructor(supabaseService, supabaseUserService) {
        this.supabaseService = supabaseService;
        this.supabaseUserService = supabaseUserService;
    }
    async validateUser(email, password) {
        const { data, error } = await this.supabaseService.getAuth().signInWithPassword({
            email,
            password,
        });
        if (error) {
            throw new common_1.UnauthorizedException('Geçersiz kimlik bilgileri');
        }
        const user = await this.supabaseUserService.findById(data.user.id);
        await this.supabaseUserService.updateLastLogin(user.id);
        return user;
    }
    async login(user) {
        const { data, error } = await this.supabaseService.getAuth().admin.generateLink({
            type: 'magiclink',
            email: user.email,
        });
        if (error) {
            throw new Error(`Supabase Auth hatası: ${error.message}`);
        }
        return {
            accessToken: data.properties.access_token,
            user: {
                id: user.id,
                email: user.email,
                firstName: user.firstName,
                lastName: user.lastName,
                roles: user.roles,
            },
        };
    }
    async validateToken(payload) {
        return this.supabaseUserService.findById(payload.sub);
    }
    async logout(token) {
        const { error } = await this.supabaseService.getAuth().signOut();
        if (error) {
            throw new Error(`Supabase Auth hatası: ${error.message}`);
        }
    }
    async sendPasswordResetEmail(email) {
        const { error } = await this.supabaseService.getAuth().resetPasswordForEmail(email);
        if (error) {
            throw new Error(`Supabase Auth hatası: ${error.message}`);
        }
    }
    async resetPassword(token, newPassword) {
        const { error } = await this.supabaseService.getAuth().updateUser({
            password: newPassword,
        });
        if (error) {
            throw new Error(`Supabase Auth hatası: ${error.message}`);
        }
    }
    async verifyEmail(token) {
    }
};
SupabaseAuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService,
        supabase_user_service_1.SupabaseUserService])
], SupabaseAuthService);
exports.SupabaseAuthService = SupabaseAuthService;
//# sourceMappingURL=supabase-auth.service.js.map