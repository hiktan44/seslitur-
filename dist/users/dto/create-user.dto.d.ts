export declare enum UserRole {
    GUIDE = "guide",
    PARTICIPANT = "participant"
}
export declare class CreateUserDto {
    email: string;
    first_name: string;
    last_name: string;
    password: string;
    phone_number?: string;
    role: UserRole;
}
