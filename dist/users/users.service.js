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
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("../supabase/supabase.service");
let UsersService = class UsersService {
    constructor(supabaseService) {
        this.supabaseService = supabaseService;
    }
    async create(createUserDto) {
        const { data: authData, error: authError } = await this.supabaseService
            .getClient()
            .auth.admin.createUser({
            email: createUserDto.email,
            password: createUserDto.password,
            email_confirm: true,
        });
        if (authError)
            throw authError;
        const userData = {
            id: authData.user.id,
            first_name: createUserDto.first_name,
            last_name: createUserDto.last_name,
            phone_number: createUserDto.phone_number,
            role: createUserDto.role,
        };
        const { data, error } = await this.supabaseService
            .getClient()
            .from('users')
            .insert([userData])
            .select()
            .single();
        if (error)
            throw error;
        return data;
    }
    async findAll() {
        const { data, error } = await this.supabaseService
            .getClient()
            .from('users')
            .select('*');
        if (error)
            throw error;
        return data;
    }
    async findOne(id) {
        const { data, error } = await this.supabaseService
            .getClient()
            .from('users')
            .select('*')
            .eq('id', id)
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Kullanıcı ID: ${id} bulunamadı`);
        return data;
    }
    async update(id, updateUserDto) {
        if (updateUserDto.email) {
            const { error: authError } = await this.supabaseService
                .getClient()
                .auth.admin.updateUserById(id, {
                email: updateUserDto.email,
            });
            if (authError)
                throw authError;
        }
        const { data, error } = await this.supabaseService
            .getClient()
            .from('users')
            .update({
            first_name: updateUserDto.first_name,
            last_name: updateUserDto.last_name,
            phone_number: updateUserDto.phone_number,
            role: updateUserDto.role,
            updated_at: new Date().toISOString(),
        })
            .eq('id', id)
            .select()
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Kullanıcı ID: ${id} bulunamadı`);
        return data;
    }
    async remove(id) {
        const { error: authError } = await this.supabaseService
            .getClient()
            .auth.admin.deleteUser(id);
        if (authError)
            throw authError;
        const { data, error } = await this.supabaseService
            .getClient()
            .from('users')
            .delete()
            .eq('id', id)
            .select()
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Kullanıcı ID: ${id} bulunamadı`);
        return { message: 'Kullanıcı başarıyla silindi' };
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], UsersService);
//# sourceMappingURL=users.service.js.map