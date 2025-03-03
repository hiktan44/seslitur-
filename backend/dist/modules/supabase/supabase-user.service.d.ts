import { SupabaseService } from './supabase.service';
import { User } from '../../entities/user.entity';
import { CreateUserDto } from '../user/dto/create-user.dto';
import { UpdateUserDto } from '../user/dto/update-user.dto';
import { UserStatus } from '../../interfaces/user-status.enum';
export declare class SupabaseUserService {
    private readonly supabaseService;
    constructor(supabaseService: SupabaseService);
    create(createUserDto: CreateUserDto): Promise<User>;
    findAll(): Promise<User[]>;
    findById(id: string): Promise<User>;
    findByEmail(email: string): Promise<User | null>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<User>;
    updatePassword(id: string, newPassword: string): Promise<void>;
    updateStatus(id: string, status: UserStatus): Promise<User>;
    remove(id: string): Promise<void>;
    updateLastLogin(id: string): Promise<User>;
    private mapToUserEntity;
}
