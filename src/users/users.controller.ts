import { Controller, Get, Post, Body, Patch, Param, Delete, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@ApiTags('Kullanıcılar')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @ApiOperation({ summary: 'Yeni kullanıcı oluştur' })
  @ApiResponse({ status: 201, description: 'Kullanıcı başarıyla oluşturuldu.' })
  @ApiResponse({ status: 400, description: 'Geçersiz veri.' })
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  @ApiOperation({ summary: 'Tüm kullanıcıları getir' })
  @ApiResponse({ status: 200, description: 'Kullanıcılar başarıyla getirildi.' })
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'ID ile kullanıcı getir' })
  @ApiParam({ name: 'id', description: 'Kullanıcı ID' })
  @ApiResponse({ status: 200, description: 'Kullanıcı başarıyla getirildi.' })
  @ApiResponse({ status: 404, description: 'Kullanıcı bulunamadı.' })
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Kullanıcı bilgilerini güncelle' })
  @ApiParam({ name: 'id', description: 'Kullanıcı ID' })
  @ApiResponse({ status: 200, description: 'Kullanıcı başarıyla güncellendi.' })
  @ApiResponse({ status: 404, description: 'Kullanıcı bulunamadı.' })
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(id, updateUserDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Kullanıcı sil' })
  @ApiParam({ name: 'id', description: 'Kullanıcı ID' })
  @ApiResponse({ status: 204, description: 'Kullanıcı başarıyla silindi.' })
  @ApiResponse({ status: 404, description: 'Kullanıcı bulunamadı.' })
  remove(@Param('id') id: string) {
    return this.usersService.remove(id);
  }
} 