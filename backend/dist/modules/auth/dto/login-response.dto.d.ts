import { Role } from '../../../interfaces/role.enum';
export declare class UserInfoDto {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
    roles: Role[];
}
export declare class LoginResponseDto {
    accessToken: string;
    user: UserInfoDto;
}
