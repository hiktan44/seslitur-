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
exports.ToursService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("../supabase/supabase.service");
let ToursService = class ToursService {
    constructor(supabaseService) {
        this.supabaseService = supabaseService;
    }
    async create(createTourDto) {
        const { data, error } = await this.supabaseService
            .getClient()
            .from('tours')
            .insert([createTourDto])
            .select()
            .single();
        if (error)
            throw error;
        return data;
    }
    async findAll() {
        const { data, error } = await this.supabaseService
            .getClient()
            .from('tours')
            .select('*');
        if (error)
            throw error;
        return data;
    }
    async findOne(id) {
        const { data, error } = await this.supabaseService
            .getClient()
            .from('tours')
            .select('*')
            .eq('id', id)
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Tur ID: ${id} bulunamadı`);
        return data;
    }
    async findToursByGuide(guideId) {
        const { data, error } = await this.supabaseService
            .getClient()
            .from('tours')
            .select('*')
            .eq('guide_id', guideId);
        if (error)
            throw error;
        return data;
    }
    async findActiveTours() {
        const { data, error } = await this.supabaseService
            .getClient()
            .from('tours')
            .select('*')
            .eq('status', 'active');
        if (error)
            throw error;
        return data;
    }
    async update(id, updateTourDto) {
        const { data, error } = await this.supabaseService
            .getClient()
            .from('tours')
            .update(updateTourDto)
            .eq('id', id)
            .select()
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Tur ID: ${id} bulunamadı`);
        return data;
    }
    async remove(id) {
        const { data, error } = await this.supabaseService
            .getClient()
            .from('tours')
            .delete()
            .eq('id', id)
            .select()
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Tur ID: ${id} bulunamadı`);
        return { message: 'Tur başarıyla silindi' };
    }
};
exports.ToursService = ToursService;
exports.ToursService = ToursService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], ToursService);
//# sourceMappingURL=tours.service.js.map