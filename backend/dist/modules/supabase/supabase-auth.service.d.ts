import { SupabaseService } from './supabase.service';
import { SupabaseUserService } from './supabase-user.service';
import { User } from '../../entities/user.entity';
import { JwtPayload } from '../auth/interfaces/jwt-payload.interface';
import { LoginResponseDto } from '../auth/dto/login-response.dto';
export declare class SupabaseAuthService {
    private readonly supabaseService;
    private readonly supabaseUserService;
    constructor(supabaseService: SupabaseService, supabaseUserService: SupabaseUserService);
    validateUser(email: string, password: string): Promise<User>;
    login(user: User): Promise<LoginResponseDto>;
    validateToken(payload: JwtPayload): Promise<User>;
    logout(token: string): Promise<void>;
    sendPasswordResetEmail(email: string): Promise<void>;
    resetPassword(token: string, newPassword: string): Promise<void>;
    verifyEmail(token: string): Promise<void>;
}
