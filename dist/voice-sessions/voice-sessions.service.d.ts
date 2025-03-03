import { SupabaseService } from '../supabase/supabase.service';
import { CreateVoiceSessionDto } from './dto/create-voice-session.dto';
import { UpdateVoiceSessionDto } from './dto/update-voice-session.dto';
export declare class VoiceSessionsService {
    private readonly supabaseService;
    constructor(supabaseService: SupabaseService);
    create(createVoiceSessionDto: CreateVoiceSessionDto): Promise<any>;
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findByTour(tourId: string): Promise<any[]>;
    findActiveSessions(): Promise<any[]>;
    update(id: string, updateVoiceSessionDto: UpdateVoiceSessionDto): Promise<any>;
    endSession(id: string): Promise<any>;
    incrementParticipantCount(roomId: string): Promise<any>;
    decrementParticipantCount(roomId: string): Promise<any>;
    remove(id: string): Promise<{
        message: string;
    }>;
}
