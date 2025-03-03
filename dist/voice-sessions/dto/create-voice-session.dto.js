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
exports.CreateVoiceSessionDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class CreateVoiceSessionDto {
}
exports.CreateVoiceSessionDto = CreateVoiceSessionDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Sesli oturumun ait olduğu tur ID',
        example: '550e8400-e29b-41d4-a716-446655440000'
    }),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], CreateVoiceSessionDto.prototype, "tour_id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Sesli oturumu başlatan kullanıcı ID',
        example: '550e8400-e29b-41d4-a716-446655440000'
    }),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], CreateVoiceSessionDto.prototype, "started_by", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Sesli oturum durumu',
        enum: ['active', 'paused', 'ended'],
        default: 'active',
        required: false
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsEnum)(['active', 'paused', 'ended']),
    __metadata("design:type", String)
], CreateVoiceSessionDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Ses kalitesi ayarı',
        enum: ['low', 'medium', 'high'],
        default: 'medium',
        required: false
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsEnum)(['low', 'medium', 'high']),
    __metadata("design:type", String)
], CreateVoiceSessionDto.prototype, "audio_quality", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Başlangıç katılımcı sayısı',
        default: 0,
        required: false
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], CreateVoiceSessionDto.prototype, "participants_count", void 0);
//# sourceMappingURL=create-voice-session.dto.js.map