import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const { full_name, email, phone, designation, password } = await req.json()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Create auth user with teacher role
    const { data: authData, error: authError } =
      await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: {
          full_name,
          role: 'teacher',
        },
      })

    if (authError) {
      return new Response(
        JSON.stringify({ success: false, error: authError.message }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 },
      )
    }

    const userId = authData.user.id

    // Insert into teachers table
    const { error: dbError } = await supabase.from('teachers').insert({
      id: userId,
      full_name,
      email,
      phone,
      designation,
      is_approved: true,
      is_active: true,
    })

    if (dbError) {
      // Rollback — delete the auth user we just created
      await supabase.auth.admin.deleteUser(userId)
      return new Response(
        JSON.stringify({ success: false, error: dbError.message }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 },
      )
    }

    return new Response(
      JSON.stringify({ success: true, teacher_id: userId }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 },
    )
  } catch (e) {
    return new Response(
      JSON.stringify({ success: false, error: String(e) }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 },
    )
  }
})