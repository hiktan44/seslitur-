import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../../interfaces/role.enum';
import { UserStatus } from '../../interfaces/user-status.enum';
import { UpdatePasswordDto } from './dto/update-password.dto';

/**
 * Kullanıcı Kontrolcüsü
 * 
 * Kullanıcı yönetimi ile ilgili HTTP endpoint'lerini içerir
 */
@ApiTags('users')
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  /**
   * Yeni bir kullanıcı oluşturur
   */
  @ApiOperation({ summary: 'Yeni bir kullanıcı oluşturur' })
  @ApiResponse({
    status: 201,
    description: 'Kullanıcı başarıyla oluşturuldu',
  })
  @ApiResponse({
    status: 400,
    description: 'Geçersiz veri',
  })
  @ApiResponse({
    status: 409,
    description: 'E-posta adresi zaten kullanılıyor',
  })
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createUserDto: CreateUserDto) {
    return this.userService.create(createUserDto);
  }

  /**
   * Tüm kullanıcıları getirir (sadece admin)
   */
  @ApiOperation({ summary: 'Tüm kullanıcıları getirir' })
  @ApiResponse({
    status: 200,
    description: 'Kullanıcı listesi başarıyla getirildi',
  })
  @ApiResponse({
    status: 401,
    description: 'Yetkisiz erişim',
  })
  @ApiResponse({
    status: 403,
    description: 'Erişim reddedildi',
  })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN, Role.SUPER_ADMIN)
  @Get()
  findAll() {
    return this.userService.findAll();
  }

  /**
   * Mevcut kullanıcının bilgilerini getirir
   */
  @ApiOperation({ summary: 'Mevcut kullanıcının bilgilerini getirir' })
  @ApiResponse({
    status: 200,
    description: 'Kullanıcı bilgileri başarıyla getirildi',
  })
  @ApiResponse({
    status: 401,
    description: 'Yetkisiz erişim',
  })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('me')
  findMe() {
    // Not: Gerçek implementasyonda JWT'den kullanıcı ID'si alınacak
    // Şimdilik sadece metod imzası oluşturuldu
    return { message: 'Mevcut kullanıcı bilgileri' };
  }

  /**
   * ID'ye göre kullanıcı getirir
   */
  @ApiOperation({ summary: 'ID\'ye göre kullanıcı getirir' })
  @ApiParam({ name: 'id', description: 'Kullanıcı ID\'si' })
  @ApiResponse({
    status: 200,
    description: 'Kullanıcı başarıyla getirildi',
  })
  @ApiResponse({
    status: 401,
    description: 'Yetkisiz erişim',
  })
  @ApiResponse({
    status: 404,
    description: 'Kullanıcı bulunamadı',
  })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userService.findById(id);
  }

  /**
   * Kullanıcı bilgilerini günceller
   */
  @ApiOperation({ summary: 'Kullanıcı bilgilerini günceller' })
  @ApiParam({ name: 'id', description: 'Kullanıcı ID\'si' })
  @ApiResponse({
    status: 200,
    description: 'Kullanıcı başarıyla güncellendi',
  })
  @ApiResponse({
    status: 400,
    description: 'Geçersiz veri',
  })
  @ApiResponse({
    status: 401,
    description: 'Yetkisiz erişim',
  })
  @ApiResponse({
    status: 404,
    description: 'Kullanıcı bulunamadı',
  })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.userService.update(id, updateUserDto);
  }

  /**
   * Kullanıcı parolasını günceller
   */
  @ApiOperation({ summary: 'Kullanıcı parolasını günceller' })
  @ApiParam({ name: 'id', description: 'Kullanıcı ID\'si' })
  @ApiResponse({
    status: 200,
    description: 'Parola başarıyla güncellendi',
  })
  @ApiResponse({
    status: 400,
    description: 'Geçersiz veri',
  })
  @ApiResponse({
    status: 401,
    description: 'Yetkisiz erişim',
  })
  @ApiResponse({
    status: 404,
    description: 'Kullanıcı bulunamadı',
  })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Patch(':id/password')
  updatePassword(@Param('id') id: string, @Body() updatePasswordDto: UpdatePasswordDto) {
    return this.userService.updatePassword(id, updatePasswordDto.newPassword);
  }

  /**
   * Kullanıcı durumunu günceller (sadece admin)
   */
  @ApiOperation({ summary: 'Kullanıcı durumunu günceller' })
  @ApiParam({ name: 'id', description: 'Kullanıcı ID\'si' })
  @ApiQuery({
    name: 'status',
    enum: UserStatus,
    description: 'Yeni kullanıcı durumu',
  })
  @ApiResponse({
    status: 200,
    description: 'Kullanıcı durumu başarıyla güncellendi',
  })
  @ApiResponse({
    status: 401,
    description: 'Yetkisiz erişim',
  })
  @ApiResponse({
    status: 403,
    description: 'Erişim reddedildi',
  })
  @ApiResponse({
    status: 404,
    description: 'Kullanıcı bulunamadı',
  })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN, Role.SUPER_ADMIN)
  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Query('status') status: UserStatus) {
    return this.userService.updateStatus(id, status);
  }

  /**
   * Kullanıcıyı siler (sadece admin)
   */
  @ApiOperation({ summary: 'Kullanıcıyı siler' })
  @ApiParam({ name: 'id', description: 'Kullanıcı ID\'si' })
  @ApiResponse({
    status: 204,
    description: 'Kullanıcı başarıyla silindi',
  })
  @ApiResponse({
    status: 401,
    description: 'Yetkisiz erişim',
  })
  @ApiResponse({
    status: 403,
    description: 'Erişim reddedildi',
  })
  @ApiResponse({
    status: 404,
    description: 'Kullanıcı bulunamadı',
  })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN, Role.SUPER_ADMIN)
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.userService.remove(id);
  }
} 