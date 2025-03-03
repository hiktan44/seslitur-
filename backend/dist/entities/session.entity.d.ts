import { User } from './user.entity';
import { Group } from './group.entity';
import { SessionStatus } from '../interfaces/session-status.enum';
export declare class Session {
    id: string;
    name: string;
    description: string;
    group: Group;
    groupId: string;
    creator: User;
    creatorId: string;
    participants: User[];
    activeSpeakerId: string;
    status: SessionStatus;
    scheduledStartTime: Date;
    actualStartTime: Date;
    endTime: Date;
    maxDuration: number;
    recordingUrl: string;
    settings: Record<string, any>;
    createdAt: Date;
    updatedAt: Date;
}
