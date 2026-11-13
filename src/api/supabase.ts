import { createClient } from '@supabase/supabase-js'
import { SB_PUB, SB_URL } from '@src/config'

export const supabase = createClient(SB_URL, SB_PUB)
