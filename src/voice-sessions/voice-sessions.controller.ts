import { Controller, Get, Post, Body, Patch, Param, Delete, HttpCode, HttpStatus } from '@nestjs/common';
import { VoiceSessionsService } from './voice-sessions.service';
import { CreateVoiceSessionDto } from './dto/create-voice-session.dto';
import { UpdateVoiceSessionDto } from './dto/update-voice-session.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiParam } from '@nestjs/swagger';

@ApiTags('voice-sessions')
@Controller('voice-sessions')
export class VoiceSessionsController {
  constructor(private readonly voiceSessionsService: VoiceSessionsService) {}

  /**
   * Yeni bir sesli oturum oluşturur
   */
  @ApiOperation({ summary: 'Yeni sesli oturum oluştur' })
  @ApiResponse({ status: 201, description: 'Sesli oturum başarıyla oluşturuldu.' })
  @ApiResponse({ status: 400, description: 'Hatalı istek.' })
  @Post()
  create(@Body() createVoiceSessionDto: CreateVoiceSessionDto) {
    return this.voiceSessionsService.create(createVoiceSessionDto);
  }

  /**
   * Tüm sesli oturumları getirir
   */
  @ApiOperation({ summary: 'Tüm sesli oturumları listele' })
  @ApiResponse({ status: 200, description: 'Sesli oturumlar başarıyla getirildi.' })
  @Get()
  findAll() {
    return this.voiceSessionsService.findAll();
  }

  /**
   * Aktif sesli oturumları getirir
   */
  @ApiOperation({ summary: 'Aktif sesli oturumları listele' })
  @ApiResponse({ status: 200, description: 'Aktif sesli oturumlar başarıyla getirildi.' })
  @Get('active')
  findActive() {
    return this.voiceSessionsService.findActiveSessions();
  }

  /**
   * ID'ye göre sesli oturum getirir
   */
  @ApiOperation({ summary: 'ID\'ye göre sesli oturum getir' })
  @ApiResponse({ status: 200, description: 'Sesli oturum başarıyla getirildi.' })
  @ApiResponse({ status: 404, description: 'Sesli oturum bulunamadı.' })
  @ApiParam({ name: 'id', description: 'Sesli oturum ID' })
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.voiceSessionsService.findOne(id);
  }

  /**
   * Tura göre sesli oturumları getirir
   */
  @ApiOperation({ summary: 'Tura göre sesli oturumları listele' })
  @ApiResponse({ status: 200, description: 'Tura ait sesli oturumlar başarıyla getirildi.' })
  @ApiParam({ name: 'tourId', description: 'Tur ID' })
  @Get('by-tour/:tourId')
  findByTour(@Param('tourId') tourId: string) {
    return this.voiceSessionsService.findByTour(tourId);
  }

  /**
   * Sesli oturumu günceller
   */
  @ApiOperation({ summary: 'Sesli oturumu güncelle' })
  @ApiResponse({ status: 200, description: 'Sesli oturum başarıyla güncellendi.' })
  @ApiResponse({ status: 404, description: 'Sesli oturum bulunamadı.' })
  @ApiParam({ name: 'id', description: 'Sesli oturum ID' })
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateVoiceSessionDto: UpdateVoiceSessionDto) {
    return this.voiceSessionsService.update(id, updateVoiceSessionDto);
  }

  /**
   * Sesli oturumu sonlandırır
   */
  @ApiOperation({ summary: 'Sesli oturumu sonlandır' })
  @ApiResponse({ status: 200, description: 'Sesli oturum başarıyla sonlandırıldı.' })
  @ApiResponse({ status: 404, description: 'Sesli oturum bulunamadı.' })
  @ApiParam({ name: 'id', description: 'Sesli oturum ID' })
  @Patch(':id/end')
  endSession(@Param('id') id: string) {
    return this.voiceSessionsService.endSession(id);
  }

  /**
   * Oturumun katılımcı sayısını artırır
   */
  @ApiOperation({ summary: 'Katılımcı sayısını artır' })
  @ApiResponse({ status: 200, description: 'Katılımcı sayısı başarıyla artırıldı.' })
  @ApiResponse({ status: 404, description: 'Sesli oturum bulunamadı.' })
  @ApiParam({ name: 'id', description: 'Sesli oturum ID' })
  @Patch(':id/increment-participants')
  incrementParticipants(@Param('id') id: string) {
    return this.voiceSessionsService.incrementParticipantCount(id);
  }

  /**
   * Oturumun katılımcı sayısını azaltır
   */
  @ApiOperation({ summary: 'Katılımcı sayısını azalt' })
  @ApiResponse({ status: 200, description: 'Katılımcı sayısı başarıyla azaltıldı.' })
  @ApiResponse({ status: 404, description: 'Sesli oturum bulunamadı.' })
  @ApiParam({ name: 'id', description: 'Sesli oturum ID' })
  @Patch(':id/decrement-participants')
  decrementParticipants(@Param('id') id: string) {
    return this.voiceSessionsService.decrementParticipantCount(id);
  }

  /**
   * Sesli oturumu siler
   */
  @ApiOperation({ summary: 'Sesli oturumu sil' })
  @ApiResponse({ status: 204, description: 'Sesli oturum başarıyla silindi.' })
  @ApiResponse({ status: 404, description: 'Sesli oturum bulunamadı.' })
  @ApiParam({ name: 'id', description: 'Sesli oturum ID' })
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.voiceSessionsService.remove(id);
  }
} 