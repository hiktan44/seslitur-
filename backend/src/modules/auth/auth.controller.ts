import {
  Controller,
  Post,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
  Get,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { LoginResponseDto } from './dto/login-response.dto';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

/**
 * Kimlik Doğrulama Kontrolcüsü
 * 
 * Kullanıcı kimlik doğrulama ve yetkilendirme işlemleri için HTTP endpoint'leri
 */
@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Kullanıcı girişi yapar
   */
  @ApiOperation({ summary: 'Kullanıcı girişi yapar' })
  @ApiResponse({
    status: 200,
    description: 'Başarılı giriş',
    type: LoginResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Geçersiz kimlik bilgileri',
  })
  @UseGuards(LocalAuthGuard)
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto, @Request() req): Promise<LoginResponseDto> {
    return this.authService.login(req.user);
  }

  /**
   * Mevcut kullanıcı bilgilerini getirir
   */
  @ApiOperation({ summary: 'Mevcut kullanıcı bilgilerini getirir' })
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
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }
} 