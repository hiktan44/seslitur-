// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

console.log("TurSesli Edge Fonksiyonu çalışıyor!")

serve(async (req) => {
  const { name } = await req.json()
  const data = {
    message: `Merhaba ${name || 'Dünya'}! TurSesli API'sine hoş geldiniz.`,
    timestamp: new Date().toISOString(),
    version: "1.0.0",
    service: "TurSesli Sesli İletişim Sistemi"
  }

  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } },
  )
})

/* Yerel olarak çağırmak için:

  1. `supabase start` komutunu çalıştırın (bkz: https://supabase.com/docs/reference/cli/supabase-start)
  2. HTTP isteği yapın:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/hello-world' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"TurSesli"}'

*/ 