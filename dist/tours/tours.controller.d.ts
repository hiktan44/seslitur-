import { ToursService } from './tours.service';
import { CreateTourDto } from './dto/create-tour.dto';
import { UpdateTourDto } from './dto/update-tour.dto';
export declare class ToursController {
    private readonly toursService;
    constructor(toursService: ToursService);
    create(createTourDto: CreateTourDto): Promise<any>;
    findAll(): Promise<any[]>;
    findActiveTours(): Promise<any[]>;
    findToursByGuide(guideId: string): Promise<any[]>;
    findOne(id: string): Promise<any>;
    update(id: string, updateTourDto: UpdateTourDto): Promise<any>;
    remove(id: string): Promise<{
        message: string;
    }>;
}
