import { createClient } from '@supabase/supabase-js';

/**
 * Supabase İstemcisi
 * 
 * Supabase ile iletişim kurmak için kullanılan istemci
 */
const supabaseUrl = process.env.REACT_APP_SUPABASE_URL || '';
const supabaseKey = process.env.REACT_APP_SUPABASE_KEY || '';

if (!supabaseUrl || !supabaseKey) {
  console.error('Supabase yapılandırması eksik. REACT_APP_SUPABASE_URL ve REACT_APP_SUPABASE_KEY çevre değişkenleri gereklidir.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

export default supabase; 