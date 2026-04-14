import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// Usamos la librería oficial de Google para evitar errores de módulos caídos
import { JWT } from "npm:google-auth-library@9"

serve(async (req) => {
  try {
    // 1. Recibimos los datos desde Flutter
    const { deviceToken, title, body } = await req.json()

    // 2. Traemos las llaves que guardamos en los "Secrets"
    const clientEmail = Deno.env.get('FCM_CLIENT_EMAIL')!
    const privateKey = Deno.env.get('FCM_PRIVATE_KEY')!.replace(/\\n/g, '\n')
    const projectId = Deno.env.get('FCM_PROJECT_ID')!

    // 3. Preparamos la autenticación con Google (OAuth2)
    const jwt = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })

    // Generamos el token de acceso
    const tokenInfo = await jwt.getAccessToken()
    const accessToken = tokenInfo.token

    // 4. Creamos el cuerpo de la notificación (Estructura HTTP v1)
    const fcmPayload = {
      message: {
        token: deviceToken,
        notification: {
          title: title,
          body: body,
        },
      },
    }

    // 5. Enviamos la petición a Google
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(fcmPayload),
      }
    )

    const data = await res.json()
    return new Response(JSON.stringify(data), { status: 200 })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})