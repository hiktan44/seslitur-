import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateVoiceSessionDto } from './dto/create-voice-session.dto';
import { UpdateVoiceSessionDto } from './dto/update-voice-session.dto';

@Injectable()
export class VoiceSessionsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  /**
   * Yeni bir sesli oturum oluşturur
   * @param createVoiceSessionDto Sesli oturum oluşturmak için gerekli bilgiler
   * @returns Oluşturulan sesli oturum
   */
  async create(createVoiceSessionDto: CreateVoiceSessionDto) {
    const { data, error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .insert({
        ...createVoiceSessionDto,
        participant_count: 1,
        started_at: new Date(),
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Tüm sesli oturumları getirir
   * @returns Sesli oturumlar listesi
   */
  async findAll() {
    const { data, error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .select('*');

    if (error) throw error;
    return data;
  }

  /**
   * Belirli bir sesli oturumu ID'sine göre getirir
   * @param id Sesli oturum ID
   * @returns Sesli oturum
   */
  async findOne(id: string) {
    const { data, error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Sesli oturum #${id} bulunamadı`);
    return data;
  }

  /**
   * Belirli bir tura ait sesli oturumları getirir
   * @param tourId Tur ID
   * @returns Tura ait sesli oturumlar
   */
  async findByTour(tourId: string) {
    const { data, error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .select('*')
      .eq('tour_id', tourId);

    if (error) throw error;
    return data;
  }

  /**
   * Aktif sesli oturumları getirir
   * @returns Aktif sesli oturumlar listesi
   */
  async findActiveSessions() {
    const { data, error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .select('*')
      .eq('status', 'active');

    if (error) throw error;
    return data;
  }

  /**
   * Sesli oturum bilgilerini günceller
   * @param id Güncellenecek sesli oturum ID
   * @param updateVoiceSessionDto Güncellenecek bilgiler
   * @returns Güncellenen sesli oturum
   */
  async update(id: string, updateVoiceSessionDto: UpdateVoiceSessionDto) {
    const { data, error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .update(updateVoiceSessionDto)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Sesli oturum #${id} bulunamadı`);
    return data;
  }

  /**
   * Sesli oturumu sonlandırır
   * @param id Sonlandırılacak sesli oturum ID
   * @returns Sonlandırılan sesli oturum
   */
  async endSession(id: string) {
    const { data, error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .update({
        status: 'ended',
        ended_at: new Date(),
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Sesli oturum #${id} bulunamadı`);
    return data;
  }

  /**
   * Sesli oturumun katılımcı sayısını artırır
   * @param id Sesli oturum ID
   * @returns Güncellenen sesli oturum
   */
  async incrementParticipantCount(roomId: string) {
    const { data, error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .select('participant_count')
      .eq('id', roomId)
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Sesli oturum #${roomId} bulunamadı`);

    const newCount = (data.participant_count || 0) + 1;

    const { data: updatedData, error: updateError } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .update({ participant_count: newCount })
      .eq('id', roomId)
      .select()
      .single();

    if (updateError) throw updateError;
    return updatedData;
  }

  /**
   * Sesli oturumun katılımcı sayısını azaltır
   * @param id Sesli oturum ID
   * @returns Güncellenen sesli oturum
   */
  async decrementParticipantCount(roomId: string) {
    const { data, error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .select('participant_count')
      .eq('id', roomId)
      .single();

    if (error) throw error;
    if (!data) throw new NotFoundException(`Sesli oturum #${roomId} bulunamadı`);

    const newCount = Math.max((data.participant_count || 0) - 1, 0);

    const { data: updatedData, error: updateError } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .update({ participant_count: newCount })
      .eq('id', roomId)
      .select()
      .single();

    if (updateError) throw updateError;
    return updatedData;
  }

  /**
   * Sesli oturumu siler
   * @param id Silinecek sesli oturum ID
   * @returns Başarı mesajı
   */
  async remove(id: string) {
    const { error } = await this.supabaseService.getClient()
      .from('voice_sessions')
      .delete()
      .eq('id', id);

    if (error) throw error;
    return { message: `Sesli oturum #${id} başarıyla silindi` };
  }
} 