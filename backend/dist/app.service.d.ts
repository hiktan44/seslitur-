import { ConfigService } from '@nestjs/config';
export declare class AppService {
    private readonly configService;
    constructor(configService: ConfigService);
    getHello(): {
        message: string;
        version: string;
        timestamp: string;
    };
    getHealth(): {
        status: string;
        timestamp: string;
        uptime: number;
        version: string;
        environment: string;
    };
}
