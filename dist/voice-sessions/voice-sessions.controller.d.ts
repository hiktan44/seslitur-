import { VoiceSessionsService } from './voice-sessions.service';
import { CreateVoiceSessionDto } from './dto/create-voice-session.dto';
import { UpdateVoiceSessionDto } from './dto/update-voice-session.dto';
export declare class VoiceSessionsController {
    private readonly voiceSessionsService;
    constructor(voiceSessionsService: VoiceSessionsService);
    create(createVoiceSessionDto: CreateVoiceSessionDto): Promise<any>;
    findAll(): Promise<any[]>;
    findActive(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findByTour(tourId: string): Promise<any[]>;
    update(id: string, updateVoiceSessionDto: UpdateVoiceSessionDto): Promise<any>;
    endSession(id: string): Promise<any>;
    incrementParticipants(id: string): Promise<any>;
    decrementParticipants(id: string): Promise<any>;
    remove(id: string): Promise<{
        message: string;
    }>;
}
