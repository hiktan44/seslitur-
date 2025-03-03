import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserStatus } from '../../interfaces/user-status.enum';
import { UpdatePasswordDto } from './dto/update-password.dto';
export declare class UserController {
    private readonly userService;
    constructor(userService: UserService);
    create(createUserDto: CreateUserDto): Promise<import("../../entities/user.entity").User>;
    findAll(): Promise<import("../../entities/user.entity").User[]>;
    findMe(): {
        message: string;
    };
    findOne(id: string): Promise<import("../../entities/user.entity").User>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<import("../../entities/user.entity").User>;
    updatePassword(id: string, updatePasswordDto: UpdatePasswordDto): Promise<import("../../entities/user.entity").User>;
    updateStatus(id: string, status: UserStatus): Promise<import("../../entities/user.entity").User>;
    remove(id: string): Promise<void>;
}
