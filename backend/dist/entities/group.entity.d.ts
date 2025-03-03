import { User } from './user.entity';
import { Session } from './session.entity';
export declare class Group {
    id: string;
    name: string;
    description: string;
    imageUrl: string;
    passwordHash: string;
    members: User[];
    admins: User[];
    sessions: Session[];
    maxMembers: number;
    settings: Record<string, any>;
    createdAt: Date;
    updatedAt: Date;
}
