import api from './api';

/**
 * Oturum Servisi
 * 
 * Sesli iletişim oturumları yönetimi işlemlerini gerçekleştiren servis
 */

export interface Session {
  id: string;
  groupId: string;
  name: string;
  description?: string;
  startTime: string;
  endTime?: string;
  status: 'scheduled' | 'active' | 'ended' | 'cancelled';
  moderatorId: string;
  maxParticipants: number;
  currentParticipants: number;
  createdAt: string;
  updatedAt: string;
}

export interface CreateSessionDto {
  groupId: string;
  name: string;
  description?: string;
  startTime?: string;
  maxParticipants?: number;
}

export interface UpdateSessionDto {
  name?: string;
  description?: string;
  startTime?: string;
  maxParticipants?: number;
}

/**
 * Oturum oluşturur
 * 
 * @param data - Oturum oluşturma DTO'su
 * @returns Oluşturulan oturum
 */
export const createSession = async (data: CreateSessionDto): Promise<Session> => {
  try {
    const response = await api.post<Session>('/sessions', data);
    return response.data;
  } catch (error) {
    console.error('Oturum oluşturma hatası:', error);
    throw error;
  }
};

/**
 * Grup oturumlarını getirir
 * 
 * @param groupId - Grup ID'si
 * @returns Oturum listesi
 */
export const getGroupSessions = async (groupId: string): Promise<Session[]> => {
  try {
    const response = await api.get<Session[]>(`/sessions/group/${groupId}`);
    return response.data;
  } catch (error) {
    console.error('Grup oturumlarını getirme hatası:', error);
    throw error;
  }
};

/**
 * Kullanıcının oturumlarını getirir
 * 
 * @returns Kullanıcının oturum listesi
 */
export const getUserSessions = async (): Promise<Session[]> => {
  try {
    const response = await api.get<Session[]>('/sessions/user');
    return response.data;
  } catch (error) {
    console.error('Kullanıcı oturumlarını getirme hatası:', error);
    throw error;
  }
};

/**
 * ID'ye göre oturum getirir
 * 
 * @param id - Oturum ID'si
 * @returns Oturum
 */
export const getSessionById = async (id: string): Promise<Session> => {
  try {
    const response = await api.get<Session>(`/sessions/${id}`);
    return response.data;
  } catch (error) {
    console.error('Oturum getirme hatası:', error);
    throw error;
  }
};

/**
 * Oturumu günceller
 * 
 * @param id - Oturum ID'si
 * @param data - Oturum güncelleme DTO'su
 * @returns Güncellenmiş oturum
 */
export const updateSession = async (id: string, data: UpdateSessionDto): Promise<Session> => {
  try {
    const response = await api.put<Session>(`/sessions/${id}`, data);
    return response.data;
  } catch (error) {
    console.error('Oturum güncelleme hatası:', error);
    throw error;
  }
};

/**
 * Oturumu siler
 * 
 * @param id - Oturum ID'si
 */
export const deleteSession = async (id: string): Promise<void> => {
  try {
    await api.delete(`/sessions/${id}`);
  } catch (error) {
    console.error('Oturum silme hatası:', error);
    throw error;
  }
};

/**
 * Oturumu başlatır
 * 
 * @param id - Oturum ID'si
 * @returns Başlatılan oturum
 */
export const startSession = async (id: string): Promise<Session> => {
  try {
    const response = await api.post<Session>(`/sessions/${id}/start`);
    return response.data;
  } catch (error) {
    console.error('Oturum başlatma hatası:', error);
    throw error;
  }
};

/**
 * Oturumu sonlandırır
 * 
 * @param id - Oturum ID'si
 * @returns Sonlandırılan oturum
 */
export const endSession = async (id: string): Promise<Session> => {
  try {
    const response = await api.post<Session>(`/sessions/${id}/end`);
    return response.data;
  } catch (error) {
    console.error('Oturum sonlandırma hatası:', error);
    throw error;
  }
};

/**
 * Oturuma katılır
 * 
 * @param id - Oturum ID'si
 * @returns Katılınan oturum
 */
export const joinSession = async (id: string): Promise<Session> => {
  try {
    const response = await api.post<Session>(`/sessions/${id}/join`);
    return response.data;
  } catch (error) {
    console.error('Oturuma katılma hatası:', error);
    throw error;
  }
};

/**
 * Oturumdan ayrılır
 * 
 * @param id - Oturum ID'si
 */
export const leaveSession = async (id: string): Promise<void> => {
  try {
    await api.post(`/sessions/${id}/leave`);
  } catch (error) {
    console.error('Oturumdan ayrılma hatası:', error);
    throw error;
  }
};

/**
 * Oturum katılımcılarını getirir
 * 
 * @param id - Oturum ID'si
 * @returns Katılımcı listesi
 */
export const getSessionParticipants = async (id: string): Promise<any[]> => {
  try {
    const response = await api.get<any[]>(`/sessions/${id}/participants`);
    return response.data;
  } catch (error) {
    console.error('Oturum katılımcılarını getirme hatası:', error);
    throw error;
  }
}; 