import { SupabaseService } from '../supabase/supabase.service';
import { CreateTourDto } from './dto/create-tour.dto';
import { UpdateTourDto } from './dto/update-tour.dto';
export declare class ToursService {
    private readonly supabaseService;
    constructor(supabaseService: SupabaseService);
    create(createTourDto: CreateTourDto): Promise<any>;
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    findToursByGuide(guideId: string): Promise<any[]>;
    findActiveTours(): Promise<any[]>;
    update(id: string, updateTourDto: UpdateTourDto): Promise<any>;
    remove(id: string): Promise<{
        message: string;
    }>;
}
