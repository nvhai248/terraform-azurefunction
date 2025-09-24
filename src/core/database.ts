// src/lib/supabase.ts
import { createClient } from "@supabase/supabase-js";

// Extend globalThis so we can cache the client.
const globalForSupabase = globalThis as unknown as {
  supabase: ReturnType<typeof createClient> | undefined;
};

export const supabase =
  globalForSupabase.supabase ??
  createClient(process.env.SUPABASE_URL!, process.env.SUPABASE_KEY!, {
    auth: { persistSession: false },
  });

if (process.env.NODE_ENV !== "production") {
  globalForSupabase.supabase = supabase;
}
