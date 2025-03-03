import { Controller, Get, Post, Body, Patch, Param, Delete, HttpCode, HttpStatus, Query } from '@nestjs/common';
import { ToursService } from './tours.service';
import { CreateTourDto } from './dto/create-tour.dto';
import { UpdateTourDto } from './dto/update-tour.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';

@ApiTags('tours')
@Controller('tours')
export class ToursController {
  constructor(private readonly toursService: ToursService) {}

  @Post()
  @ApiOperation({ summary: 'Yeni bir tur oluştur' })
  @ApiResponse({ status: 201, description: 'Tur başarıyla oluşturuldu' })
  @ApiResponse({ status: 400, description: 'Geçersiz veri' })
  create(@Body() createTourDto: CreateTourDto) {
    return this.toursService.create(createTourDto);
  }

  @Get()
  @ApiOperation({ summary: 'Tüm turları getir' })
  @ApiResponse({ status: 200, description: 'Turlar başarıyla getirildi' })
  findAll() {
    return this.toursService.findAll();
  }

  @Get('active')
  @ApiOperation({ summary: 'Aktif turları getir' })
  @ApiResponse({ status: 200, description: 'Aktif turlar başarıyla getirildi' })
  findActiveTours() {
    return this.toursService.findActiveTours();
  }

  @Get('guide/:guideId')
  @ApiOperation({ summary: 'Rehbere göre turları getir' })
  @ApiParam({ name: 'guideId', description: 'Rehber ID' })
  @ApiResponse({ status: 200, description: 'Rehberin turları başarıyla getirildi' })
  findToursByGuide(@Param('guideId') guideId: string) {
    return this.toursService.findToursByGuide(guideId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'ID\'ye göre tur getir' })
  @ApiParam({ name: 'id', description: 'Tur ID' })
  @ApiResponse({ status: 200, description: 'Tur başarıyla getirildi' })
  @ApiResponse({ status: 404, description: 'Tur bulunamadı' })
  findOne(@Param('id') id: string) {
    return this.toursService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Tur bilgilerini güncelle' })
  @ApiParam({ name: 'id', description: 'Tur ID' })
  @ApiResponse({ status: 200, description: 'Tur başarıyla güncellendi' })
  @ApiResponse({ status: 404, description: 'Tur bulunamadı' })
  update(@Param('id') id: string, @Body() updateTourDto: UpdateTourDto) {
    return this.toursService.update(id, updateTourDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Turu sil' })
  @ApiParam({ name: 'id', description: 'Tur ID' })
  @ApiResponse({ status: 200, description: 'Tur başarıyla silindi' })
  @ApiResponse({ status: 404, description: 'Tur bulunamadı' })
  remove(@Param('id') id: string) {
    return this.toursService.remove(id);
  }
} 