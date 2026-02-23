from supabase import create_client, Client

SUPABASE_URL = "https://fhqiewinlrphsaottdwe.supabase.co"
SUPABASE_KEY = "sb_publishable_bqccpo7V4lW_80gLJlcpaA_enoJKY1q"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)