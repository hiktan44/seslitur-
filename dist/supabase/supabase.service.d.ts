import { OnModuleInit } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
export declare class SupabaseService implements OnModuleInit {
    private supabase;
    constructor();
    onModuleInit(): void;
    getClient(): SupabaseClient;
}
