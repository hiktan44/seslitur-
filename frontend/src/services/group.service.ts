import api from './api';

/**
 * Grup Servisi
 * 
 * Grup yönetimi işlemlerini gerçekleştiren servis
 */

export interface Group {
  id: string;
  name: string;
  description?: string;
  ownerId: string;
  isPrivate: boolean;
  isProtected: boolean;
  password?: string;
  maxParticipants: number;
  currentParticipants: number;
  createdAt: string;
  updatedAt: string;
}

export interface CreateGroupDto {
  name: string;
  description?: string;
  isPrivate: boolean;
  password?: string;
  maxParticipants: number;
  isProtected: boolean;
}

export interface UpdateGroupDto {
  name?: string;
  description?: string;
  isPrivate?: boolean;
  password?: string;
  maxParticipants?: number;
}

export interface JoinGroupDto {
  groupId: string;
  password?: string;
}

/**
 * Grup oluşturur
 * 
 * @param data - Grup oluşturma DTO'su
 * @returns Oluşturulan grup
 */
export const createGroup = async (data: CreateGroupDto): Promise<Group> => {
  try {
    const response = await api.post<Group>('/groups', data);
    return response.data;
  } catch (error) {
    console.error('Grup oluşturma hatası:', error);
    throw error;
  }
};

/**
 * Tüm grupları getirir
 * 
 * @returns Grup listesi
 */
export const getAllGroups = async (): Promise<Group[]> => {
  try {
    const response = await api.get<Group[]>('/groups');
    return response.data;
  } catch (error) {
    console.error('Grupları getirme hatası:', error);
    throw error;
  }
};

/**
 * Kullanıcının gruplarını getirir
 * 
 * @returns Kullanıcının grup listesi
 */
export const getUserGroups = async (): Promise<Group[]> => {
  try {
    const response = await api.get<Group[]>('/groups/user');
    return response.data;
  } catch (error) {
    console.error('Kullanıcı gruplarını getirme hatası:', error);
    throw error;
  }
};

/**
 * ID'ye göre grup getirir
 * 
 * @param id - Grup ID'si
 * @returns Grup
 */
export const getGroupById = async (id: string): Promise<Group> => {
  try {
    const response = await api.get<Group>(`/groups/${id}`);
    return response.data;
  } catch (error) {
    console.error('Grup getirme hatası:', error);
    throw error;
  }
};

/**
 * Grubu günceller
 * 
 * @param id - Grup ID'si
 * @param data - Grup güncelleme DTO'su
 * @returns Güncellenmiş grup
 */
export const updateGroup = async (id: string, data: UpdateGroupDto): Promise<Group> => {
  try {
    const response = await api.put<Group>(`/groups/${id}`, data);
    return response.data;
  } catch (error) {
    console.error('Grup güncelleme hatası:', error);
    throw error;
  }
};

/**
 * Grubu siler
 * 
 * @param id - Grup ID'si
 */
export const deleteGroup = async (id: string): Promise<void> => {
  try {
    await api.delete(`/groups/${id}`);
  } catch (error) {
    console.error('Grup silme hatası:', error);
    throw error;
  }
};

/**
 * Gruba katılır
 * 
 * @param data - Gruba katılma DTO'su
 * @returns Katılınan grup
 */
export const joinGroup = async (data: JoinGroupDto): Promise<Group> => {
  try {
    const response = await api.post<Group>('/groups/join', data);
    return response.data;
  } catch (error) {
    console.error('Gruba katılma hatası:', error);
    throw error;
  }
};

/**
 * Gruptan ayrılır
 * 
 * @param groupId - Grup ID'si
 */
export const leaveGroup = async (groupId: string): Promise<void> => {
  try {
    await api.post('/groups/leave', { groupId });
  } catch (error) {
    console.error('Gruptan ayrılma hatası:', error);
    throw error;
  }
};

/**
 * Grup katılımcılarını getirir
 * 
 * @param groupId - Grup ID'si
 * @returns Katılımcı listesi
 */
export const getGroupParticipants = async (groupId: string): Promise<any[]> => {
  try {
    const response = await api.get<any[]>(`/groups/${groupId}/participants`);
    return response.data;
  } catch (error) {
    console.error('Grup katılımcılarını getirme hatası:', error);
    throw error;
  }
};

/**
 * Grup oturumlarını getirir
 * 
 * @param groupId - Grup ID'si
 * @returns Oturum listesi
 */
export const getGroupSessions = async (groupId: string): Promise<any[]> => {
  try {
    const response = await api.get<any[]>(`/groups/${groupId}/sessions`);
    return response.data;
  } catch (error) {
    console.error('Grup oturumlarını getirme hatası:', error);
    throw error;
  }
}; 