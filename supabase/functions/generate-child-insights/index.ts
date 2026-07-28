import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { child_id } = await req.json()
    if (!child_id) {
      return new Response(
        JSON.stringify({ error: 'Missing child_id parameter' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing Authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase Clients
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')

    if (!geminiApiKey) {
      return new Response(
        JSON.stringify({ error: 'GEMINI_API_KEY is not configured in Supabase Secrets' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // User client (enforces RLS to check authorization)
    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } }
    })

    // Service client (bypasses RLS to query full logs and write cache)
    const serviceClient = createClient(supabaseUrl, supabaseServiceKey)

    // 1. Verify that the requesting user has permission to read this child
    const { data: child, error: childError } = await userClient
      .from('children')
      .select('id, full_name, date_of_birth, allergies, medical_notes')
      .eq('id', child_id)
      .single()

    if (childError || !child) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized or child not found' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const todayStr = new Date().toISOString().split('T')[0]

    // 2. Check if insights for this child and date already exist in the cache
    const { data: cachedInsights, error: cacheError } = await serviceClient
      .from('child_ai_insights')
      .select('*')
      .eq('child_id', child_id)
      .eq('date', todayStr)
      .maybeSingle()

    if (cachedInsights) {
      return new Response(
        JSON.stringify(cachedInsights),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 3. Fetch past 7 days of logs across activities, nutrition_records, growth_records, and incidents
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()

    const [activitiesRes, nutritionRes, growthRes, incidentsRes] = await Promise.all([
      serviceClient.from('activities').select('*').eq('child_id', child_id).gte('created_at', sevenDaysAgo),
      serviceClient.from('nutrition_records').select('*').eq('child_id', child_id).gte('created_at', sevenDaysAgo),
      serviceClient.from('growth_records').select('*').eq('child_id', child_id).gte('created_at', sevenDaysAgo),
      serviceClient.from('incidents').select('*').eq('child_id', child_id).gte('created_at', sevenDaysAgo),
    ])

    const dob = new Date(child.date_of_birth)
    const ageMonths = Math.floor((Date.now() - dob.getTime()) / (30 * 24 * 60 * 60 * 1000))

    // 4. Construct Gemini prompt
    const logsPayload = {
      child: {
        name: child.full_name,
        age_months: ageMonths,
        allergies: child.allergies || 'None',
        medical_notes: child.medical_notes || 'None',
      },
      logs: {
        general_activities: activitiesRes.data || [],
        nutrition_and_water: nutritionRes.data || [],
        growth_measurements: growthRes.data || [],
        safety_incidents: incidentsRes.data || [],
      }
    }

    const systemPrompt = "You are a professional pediatric assistant, pediatric nutritionist, and sleep training specialist. \n" +
      "Your goal is to analyze the 7-day child activity log and output structured daily suggestions for caregivers and parents.\n" +
      "Your recommendations MUST strictly avoid prescribing specific medications. Focus instead on healthy habits, routines, nutrition, hydration, and first-aid education.\n\n" +
      "You must return a single JSON object. Do not wrap the JSON in markdown code blocks. Return only the raw JSON. The response structure must match exactly:\n" +
      "{\n" +
      "  \"nutrition\": {\n" +
      "    \"analysis\": \"Brief summary of child nutrition, intake quality, or missing nutrients.\",\n" +
      "    \"suggestions\": [\"Concrete food suggestion 1\", \"Concrete food suggestion 2\"]\n" +
      "  },\n" +
      "  \"sleep\": {\n" +
      "    \"analysis\": \"Summary of sleep patterns, nap lengths, and potential fatigue indicators.\",\n" +
      "    \"suggestions\": [\"Bedtime suggestion 1\", \"Nap suggestions\"]\n" +
      "  },\n" +
      "  \"hydration\": {\n" +
      "    \"analysis\": \"Summary of fluid and water logs.\",\n" +
      "    \"suggestions\": [\"Hydration recommendation\"]\n" +
      "  },\n" +
      "  \"medical\": {\n" +
      "    \"analysis\": \"Summary of any logged safety incidents or health reports like fever/cough.\",\n" +
      "    \"suggestions\": [\"Non-prescriptive wellness tip (e.g. hydration for fever, rest, cool compression)\", \"Alert triggers (when to consult a doctor)\"]\n" +
      "  },\n" +
      "  \"growth\": {\n" +
      "    \"analysis\": \"Analysis of height/weight progress compared to standard averages.\",\n" +
      "    \"suggestions\": [\"Growth suggestions or encouraging message\"]\n" +
      "  }\n" +
      "}";

    const geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + geminiApiKey;
    
    const response = await fetch(geminiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: [
              { text: "System Instructions:\n" + systemPrompt + "\n\nChild Data & Logs:\n" + JSON.stringify(logsPayload) }
            ]
          }
        ],
        generationConfig: {
          responseMimeType: "application/json"
        }
      })
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Gemini API returned error ${response.status}: ${errorText}`)
    }

    const geminiData = await response.json()
    const contentText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text
    if (!contentText) {
      throw new Error('Invalid or empty response from Gemini API')
    }

    const parsedInsights = JSON.parse(contentText.trim())

    // 5. Cache the insights into public.child_ai_insights
    const { data: insertedInsights, error: insertError } = await serviceClient
      .from('child_ai_insights')
      .insert({
        child_id,
        date: todayStr,
        nutrition: parsedInsights.nutrition,
        sleep: parsedInsights.sleep,
        hydration: parsedInsights.hydration,
        medical: parsedInsights.medical,
        growth: parsedInsights.growth,
      })
      .select()
      .single()

    if (insertError) {
      // If cache write fails, return the parsed insights directly without breaking the request
      console.error('Failed to cache insights to database:', insertError)
      return new Response(
        JSON.stringify({
          child_id,
          date: todayStr,
          nutrition: parsedInsights.nutrition,
          sleep: parsedInsights.sleep,
          hydration: parsedInsights.hydration,
          medical: parsedInsights.medical,
          growth: parsedInsights.growth,
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify(insertedInsights),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
