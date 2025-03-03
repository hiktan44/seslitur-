import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateTourDto } from './dto/create-tour.dto';
import { UpdateTourDto } from './dto/update-tour.dto';

@Injectable()
export class ToursService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async create(createTourDto: CreateTourDto) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('tours')
      .insert([createTourDto])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async findAll() {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('tours')
      .select('*');

    if (error) throw error;
    return data;
  }

  async findOne(id: string) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('tours')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Tur ID: ${id} bulunamadı`);
    
    return data;
  }

  async findToursByGuide(guideId: string) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('tours')
      .select('*')
      .eq('guide_id', guideId);

    if (error) throw error;
    return data;
  }

  async findActiveTours() {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('tours')
      .select('*')
      .eq('status', 'active');

    if (error) throw error;
    return data;
  }

  async update(id: string, updateTourDto: UpdateTourDto) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('tours')
      .update(updateTourDto)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Tur ID: ${id} bulunamadı`);
    
    return data;
  }

  async remove(id: string) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('tours')
      .delete()
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Tur ID: ${id} bulunamadı`);
    
    return { message: 'Tur başarıyla silindi' };
  }
} 