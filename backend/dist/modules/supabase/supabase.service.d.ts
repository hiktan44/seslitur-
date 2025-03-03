import { OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SupabaseClient } from '@supabase/supabase-js';
export declare class SupabaseService implements OnModuleInit {
    private configService;
    private supabaseClient;
    constructor(configService: ConfigService);
    onModuleInit(): void;
    getClient(): SupabaseClient;
    getAuth(): import("@supabase/supabase-js/dist/module/lib/SupabaseAuthClient").SupabaseAuthClient;
    getStorage(): import("@supabase/storage-js").StorageClient;
    from(table: string): import("@supabase/postgrest-js").PostgrestQueryBuilder<any, any, string, unknown>;
    channel(): import("@supabase/supabase-js").RealtimeChannel;
}
