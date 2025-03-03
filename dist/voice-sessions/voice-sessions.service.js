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
exports.VoiceSessionsService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("../supabase/supabase.service");
let VoiceSessionsService = class VoiceSessionsService {
    constructor(supabaseService) {
        this.supabaseService = supabaseService;
    }
    async create(createVoiceSessionDto) {
        const { data, error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .insert(Object.assign(Object.assign({}, createVoiceSessionDto), { participant_count: 1, started_at: new Date() }))
            .select()
            .single();
        if (error)
            throw error;
        return data;
    }
    async findAll() {
        const { data, error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .select('*');
        if (error)
            throw error;
        return data;
    }
    async findOne(id) {
        const { data, error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .select('*')
            .eq('id', id)
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Sesli oturum #${id} bulunamadı`);
        return data;
    }
    async findByTour(tourId) {
        const { data, error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .select('*')
            .eq('tour_id', tourId);
        if (error)
            throw error;
        return data;
    }
    async findActiveSessions() {
        const { data, error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .select('*')
            .eq('status', 'active');
        if (error)
            throw error;
        return data;
    }
    async update(id, updateVoiceSessionDto) {
        const { data, error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .update(updateVoiceSessionDto)
            .eq('id', id)
            .select()
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Sesli oturum #${id} bulunamadı`);
        return data;
    }
    async endSession(id) {
        const { data, error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .update({
            status: 'ended',
            ended_at: new Date(),
        })
            .eq('id', id)
            .select()
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Sesli oturum #${id} bulunamadı`);
        return data;
    }
    async incrementParticipantCount(roomId) {
        const { data, error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .select('participant_count')
            .eq('id', roomId)
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Sesli oturum #${roomId} bulunamadı`);
        const newCount = (data.participant_count || 0) + 1;
        const { data: updatedData, error: updateError } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .update({ participant_count: newCount })
            .eq('id', roomId)
            .select()
            .single();
        if (updateError)
            throw updateError;
        return updatedData;
    }
    async decrementParticipantCount(roomId) {
        const { data, error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .select('participant_count')
            .eq('id', roomId)
            .single();
        if (error)
            throw error;
        if (!data)
            throw new common_1.NotFoundException(`Sesli oturum #${roomId} bulunamadı`);
        const newCount = Math.max((data.participant_count || 0) - 1, 0);
        const { data: updatedData, error: updateError } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .update({ participant_count: newCount })
            .eq('id', roomId)
            .select()
            .single();
        if (updateError)
            throw updateError;
        return updatedData;
    }
    async remove(id) {
        const { error } = await this.supabaseService.getClient()
            .from('voice_sessions')
            .delete()
            .eq('id', id);
        if (error)
            throw error;
        return { message: `Sesli oturum #${id} başarıyla silindi` };
    }
};
exports.VoiceSessionsService = VoiceSessionsService;
exports.VoiceSessionsService = VoiceSessionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], VoiceSessionsService);
//# sourceMappingURL=voice-sessions.service.js.map