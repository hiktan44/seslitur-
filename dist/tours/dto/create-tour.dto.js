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
exports.CreateTourDto = exports.TourStatus = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
var TourStatus;
(function (TourStatus) {
    TourStatus["UPCOMING"] = "upcoming";
    TourStatus["ACTIVE"] = "active";
    TourStatus["COMPLETED"] = "completed";
    TourStatus["CANCELLED"] = "cancelled";
})(TourStatus || (exports.TourStatus = TourStatus = {}));
class CreateTourDto {
}
exports.CreateTourDto = CreateTourDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Tur adı',
        example: 'İstanbul Tarihi Yarımada Turu',
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateTourDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Tur kodu (benzersiz)',
        example: 'IST-001',
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateTourDto.prototype, "code", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Tur destinasyonu',
        example: 'İstanbul, Türkiye',
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateTourDto.prototype, "destination", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Tur rehberinin ID\'si',
        example: '123e4567-e89b-12d3-a456-426614174000',
    }),
    (0, class_validator_1.IsUUID)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateTourDto.prototype, "guide_id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Turun başlangıç tarihi (ISO formatında)',
        example: '2024-01-01T09:00:00Z',
    }),
    (0, class_validator_1.IsDateString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateTourDto.prototype, "start_date", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Turun bitiş tarihi (ISO formatında)',
        example: '2024-01-05T18:00:00Z',
    }),
    (0, class_validator_1.IsDateString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateTourDto.prototype, "end_date", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Tur durumu',
        enum: TourStatus,
        example: TourStatus.UPCOMING,
    }),
    (0, class_validator_1.IsEnum)(TourStatus),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateTourDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Tur açıklaması',
        example: 'İstanbul\'un tarihi yarımadasını gezeceğimiz 5 günlük tur.',
        required: false,
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateTourDto.prototype, "description", void 0);
//# sourceMappingURL=create-tour.dto.js.map