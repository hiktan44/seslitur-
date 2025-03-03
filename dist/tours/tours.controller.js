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
exports.ToursController = void 0;
const common_1 = require("@nestjs/common");
const tours_service_1 = require("./tours.service");
const create_tour_dto_1 = require("./dto/create-tour.dto");
const update_tour_dto_1 = require("./dto/update-tour.dto");
const swagger_1 = require("@nestjs/swagger");
let ToursController = class ToursController {
    constructor(toursService) {
        this.toursService = toursService;
    }
    create(createTourDto) {
        return this.toursService.create(createTourDto);
    }
    findAll() {
        return this.toursService.findAll();
    }
    findActiveTours() {
        return this.toursService.findActiveTours();
    }
    findToursByGuide(guideId) {
        return this.toursService.findToursByGuide(guideId);
    }
    findOne(id) {
        return this.toursService.findOne(id);
    }
    update(id, updateTourDto) {
        return this.toursService.update(id, updateTourDto);
    }
    remove(id) {
        return this.toursService.remove(id);
    }
};
exports.ToursController = ToursController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Yeni bir tur oluştur' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: 'Tur başarıyla oluşturuldu' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: 'Geçersiz veri' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_tour_dto_1.CreateTourDto]),
    __metadata("design:returntype", void 0)
], ToursController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Tüm turları getir' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Turlar başarıyla getirildi' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], ToursController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('active'),
    (0, swagger_1.ApiOperation)({ summary: 'Aktif turları getir' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Aktif turlar başarıyla getirildi' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], ToursController.prototype, "findActiveTours", null);
__decorate([
    (0, common_1.Get)('guide/:guideId'),
    (0, swagger_1.ApiOperation)({ summary: 'Rehbere göre turları getir' }),
    (0, swagger_1.ApiParam)({ name: 'guideId', description: 'Rehber ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Rehberin turları başarıyla getirildi' }),
    __param(0, (0, common_1.Param)('guideId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ToursController.prototype, "findToursByGuide", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'ID\'ye göre tur getir' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Tur ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Tur başarıyla getirildi' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Tur bulunamadı' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ToursController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Tur bilgilerini güncelle' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Tur ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Tur başarıyla güncellendi' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Tur bulunamadı' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_tour_dto_1.UpdateTourDto]),
    __metadata("design:returntype", void 0)
], ToursController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: 'Turu sil' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'Tur ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Tur başarıyla silindi' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Tur bulunamadı' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ToursController.prototype, "remove", null);
exports.ToursController = ToursController = __decorate([
    (0, swagger_1.ApiTags)('tours'),
    (0, common_1.Controller)('tours'),
    __metadata("design:paramtypes", [tours_service_1.ToursService])
], ToursController);
//# sourceMappingURL=tours.controller.js.map