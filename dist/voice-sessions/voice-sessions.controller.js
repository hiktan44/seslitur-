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
exports.VoiceSessionsController = void 0;
const common_1 = require("@nestjs/common");
const voice_sessions_service_1 = require("./voice-sessions.service");
const create_voice_session_dto_1 = require("./dto/create-voice-session.dto");
const update_voice_session_dto_1 = require("./dto/update-voice-session.dto");
const swagger_1 = require("@nestjs/swagger");
let VoiceSessionsController = class VoiceSessionsController {
    constructor(voiceSessionsService) {
        this.voiceSessionsService = voiceSessionsService;
    }
    create(createVoiceSessionDto) {
        return this.voiceSessionsService.create(createVoiceSessionDto);
    }
    findAll() {
        return this.voiceSessionsService.findAll();
    }
    findActive() {
        return this.voiceSessionsService.findActiveSessions();
    }
    findOne(id) {
        return this.voiceSessionsService.findOne(id);
    }
    findByTour(tourId) {
        return this.voiceSessionsService.findByTour(tourId);
    }
    update(id, updateVoiceSessionDto) {
        return this.voiceSessionsService.update(id, updateVoiceSessionDto);
    }
    endSession(id) {
        return this.voiceSessionsService.endSession(id);
    }
    incrementParticipants(id) {
        return this.voiceSessionsService.incrementParticipantCount(id);
    }
    decrementParticipants(id) {
        return this.voiceSessionsService.decrementParticipantCount(id);
    }
    remove(id) {
        return this.voiceSessionsService.remove(id);
    }
};
exports.VoiceSessionsController = VoiceSessionsController;
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Yeni sesli oturum oluştur' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: 'Sesli oturum başarıyla oluşturuldu.' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: 'Hatalı istek.' }),
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_voice_session_dto_1.CreateVoiceSessionDto]),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "create", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Tüm sesli oturumları listele' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Sesli oturumlar başarıyla getirildi.' }),
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "findAll", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Aktif sesli oturumları listele' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Aktif sesli oturumlar başarıyla getirildi.' }),
    (0, common_1.Get)('active'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "findActive", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'ID\'ye göre sesli oturum getir' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Sesli oturum başarıyla getirildi.' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Sesli oturum bulunamadı.' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Sesli oturum ID' }),
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "findOne", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Tura göre sesli oturumları listele' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Tura ait sesli oturumlar başarıyla getirildi.' }),
    (0, swagger_1.ApiParam)({ name: 'tourId', description: 'Tur ID' }),
    (0, common_1.Get)('by-tour/:tourId'),
    __param(0, (0, common_1.Param)('tourId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "findByTour", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Sesli oturumu güncelle' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Sesli oturum başarıyla güncellendi.' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Sesli oturum bulunamadı.' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Sesli oturum ID' }),
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_voice_session_dto_1.UpdateVoiceSessionDto]),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "update", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Sesli oturumu sonlandır' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Sesli oturum başarıyla sonlandırıldı.' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Sesli oturum bulunamadı.' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Sesli oturum ID' }),
    (0, common_1.Patch)(':id/end'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "endSession", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Katılımcı sayısını artır' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Katılımcı sayısı başarıyla artırıldı.' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Sesli oturum bulunamadı.' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Sesli oturum ID' }),
    (0, common_1.Patch)(':id/increment-participants'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "incrementParticipants", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Katılımcı sayısını azalt' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Katılımcı sayısı başarıyla azaltıldı.' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Sesli oturum bulunamadı.' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Sesli oturum ID' }),
    (0, common_1.Patch)(':id/decrement-participants'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "decrementParticipants", null);
__decorate([
    (0, swagger_1.ApiOperation)({ summary: 'Sesli oturumu sil' }),
    (0, swagger_1.ApiResponse)({ status: 204, description: 'Sesli oturum başarıyla silindi.' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Sesli oturum bulunamadı.' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Sesli oturum ID' }),
    (0, common_1.Delete)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.NO_CONTENT),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], VoiceSessionsController.prototype, "remove", null);
exports.VoiceSessionsController = VoiceSessionsController = __decorate([
    (0, swagger_1.ApiTags)('voice-sessions'),
    (0, common_1.Controller)('voice-sessions'),
    __metadata("design:paramtypes", [voice_sessions_service_1.VoiceSessionsService])
], VoiceSessionsController);
//# sourceMappingURL=voice-sessions.controller.js.map