import { Group } from './group.entity';
import { Session } from './session.entity';
import { UserStatus } from '../interfaces/user-status.enum';
import { Role } from '../interfaces/role.enum';
export declare class User {
    id: string;
    email: string;
    phoneNumber: string;
    passwordHash: string;
    firstName: string;
    lastName: string;
    profilePicture: string;
    status: UserStatus;
    roles: Role[];
    notificationSettings: Record<string, any>;
    audioSettings: Record<string, any>;
    language: string;
    timezone: string;
    ownedGroups: Group[];
    groups: Group[];
    sessions: Session[];
    lastLoginAt: Date;
    createdAt: Date;
    updatedAt: Date;
    get fullName(): string;
}
