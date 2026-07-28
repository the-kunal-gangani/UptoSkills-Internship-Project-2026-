import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const { full_name, email, phone, designation, center_name, password } =
      await req.json()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const { data: authData, error: authError } =
      await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: {
          full_name,
          role: 'admin',
        },
      })

    if (authError) {
      return new Response(
        JSON.stringify({ success: false, error: authError.message }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 },
      )
    }

    const userId = authData.user.id

    const { error: dbError } = await supabase.from('admins').insert({
      id: userId,
      full_name,
      email,
      phone: phone ?? null,
      designation: designation ?? 'Center Director',
      center_name,
      is_active: true,
    })

    if (dbError) {
      await supabase.auth.admin.deleteUser(userId)
      return new Response(
        JSON.stringify({ success: false, error: dbError.message }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 },
      )
    }

    return new Response(
      JSON.stringify({ success: true, admin_id: userId }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 },
    )
  } catch (e) {
    return new Response(
      JSON.stringify({ success: false, error: String(e) }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 },
    )
  }
})