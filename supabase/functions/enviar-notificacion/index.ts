import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"

// --- DATOS DE TU CUENTA DE SERVICIO DE FIREBASE ---
const serviceAccount = {
  project_id: "museoum-97788",
  client_email: "firebase-adminsdk-fbsvc@museoum-97788.iam.gserviceaccount.com",
  private_key: `-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDq1aTcCLMhDqeh\nqMANXKdtW3mEjTcyslxn+CyNiu8qqvl0o2u4lEyf7cpFSgzRF3H3YUkQfnmAQGuZ\ng+Tq8ckYWoL+2wW810aj+XYLiRYpYBN090HjbT5KtLn+dyfc6H6D6j9qDt6+qf6i\ngciSS8vdUYngYWoFJBYdX04q6Bru1Ac8GIZ0x2UfWh1a+3Drx/hTwRJLRUTitZMG\nKdYHo6tEF5Yc9IvqatXjtWdmCk+zKqgQCC1AszmbFENBCAtgQh+tLhh7hilRPwsj\nyUPH5QvDYGOEjjt7Y6oAIPBJ4dHHs2Ov64OIKGAIDvCxd0977oV93DJyKT6sK3IQ\nQb8ldz4DAgMBAAECggEACaNI17ws3quNALFkZ6GVjRztR1EX/Cb3n0+MEI3frZCE\nmjj5lLYHBD2y1ZYpuxkeiC8Z29xWkAduaXrRL3B96grcIam+htbbYzzVQrlWsgFr\nh8581npaZwZOZ3dF3ECkewIacsSQ3e74vUjc516TmHRrJEzX/sVrRohUG0AZMhNo\ngGetuFzFaq8YDnxVkIOAecy81tsgta/c3OELOVwnCiBdFMt8KmOjiQt0nkCcXob5\nPH4on5CNRzwX8Rr+tykwGddzvb0TSRn5O6LJMV0fv68w+gvxAluxztrfDsYV6enR\nMuZlMYx8bB7u9VqS+EBy5Ya53DI4bqtVszI7qW+yqQKBgQD4KaBZMxf2HlZheBsS\nSNyzaIoP+35f5dvVsCEzhUmgzXJZiADAvbka75TbQXfeMD5BTt6qPce364vNrI0i\nHiawOxzo4WLi9AGGD13T80IkM6Qm84Tnd4/HSNdb5rY38olbGfN2lv4T6iBNemDk\nEk2uuSwTCeIjcXHitb8zQYSpSwKBgQDyQELsH1iOpTboQCbTOYqPWQelEQKfM6z2\nknO4Gszmz9OsV/wMoYF0JwAnA/1pauzN+mmCAoNW/XoW9EhepTTBnB8GxYv/LtEB\nFg4QiKULexZfrv8oaftUnsMVIVdWGqtvrk52k2hMiPk0S8uRxr+iR7K9ym/DftF4\nuhC/CEzDKQKBgQCrHdjpaOfO1+BsWSshkohMVXtNxfbAHXlWgZqDMhcxADknLzaF\nsMzgm+8iuKP024Mx+TZkYTFDyvGdoqu2qN+4iSpIEpHjOKmMTTA/o+8pk0pPaX9t\nM+46VinZvt5K+bxoyx4r2bXc+YXIpugEm/Jg1mJjxl7eXa1PzE7JAxZ8vQKBgQCP\njLrbVrvQU2CVAabAFeHgjd401z6ZfjKpLiF6YA85Wr/Q6ZZHGdEvNgkmFXwt4pmO\neSvaSYjwnGWjgn/77aO0csID7j3GKkTZgus0qvQ6OGcKrhUvKpYvD6EEPWyWbllW\nZZDDPRhZ+fTKI3vu1zopfJkTVAkkbFrOUluoB9AM+QKBgQCakaik7/zBFYnJZ/bt\nukq9CqMwj17BBAWn5JvARSfEU11vPDu3C99q+uC+se4gQ7AR/wQM4kFZQ1iMqbHr\nygWIv6wOq82nd1hXTDY5RAywKBKXx7flQEXGuWcaT5BvbEZh7hQLXh0nt+cclPx7\nAbpG9vGj1+pkeoMKMF/5tjqurg==\n-----END PRIVATE KEY-----`
};

// Helper: convierte ArrayBuffer a Base64URL
function arrayBufferToBase64Url(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
}

// Importa la clave PEM privada para la Web Crypto API
async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const pemBody = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\n/g, "");
  const binaryDer = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));
  return await crypto.subtle.importKey(
    "pkcs8",
    binaryDer.buffer as ArrayBuffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );
}

// Genera un Access Token de Google OAuth2 firmando un JWT con la service account
async function getGoogleAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const encodedHeader = arrayBufferToBase64Url(new TextEncoder().encode(JSON.stringify(header)).buffer as ArrayBuffer);
  const encodedClaims = arrayBufferToBase64Url(new TextEncoder().encode(JSON.stringify(claimSet)).buffer as ArrayBuffer);
  const signingInput = `${encodedHeader}.${encodedClaims}`;

  const key = await importPrivateKey(serviceAccount.private_key);
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(signingInput)
  );

  const jwt = `${signingInput}.${arrayBufferToBase64Url(signature)}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenRes.json();
  return tokenData.access_token as string;
}

// Determina el receptor y el contenido de la notificación según la tabla de origen
function resolveNotification(
  table: string,
  record: Record<string, string>
): { receptorId: string; title: string; body: string } | null {

  switch (table) {
    case "restricted_messages":
      // sender_id envía, receiver_id recibe
      return {
        receptorId: record.receiver_id,
        title: "💬 Nuevo mensaje",
        body: record.content?.slice(0, 80) || "Te enviaron un mensaje.",
      };

    case "connections":
      // requester_id solicita conexión a addressee_id
      return {
        receptorId: record.addressee_id,
        title: "🤝 Nueva solicitud de conexión",
        body: "Alguien quiere conectar contigo.",
      };

    case "in_app_notifications":
      // user_id es quien recibe la notificación
      return {
        receptorId: record.user_id,
        title: "🔔 Nueva notificación",
        body: record.tipo === "like"
          ? "A alguien le gustó tu publicación."
          : record.tipo === "comment"
          ? "Alguien comentó en tu publicación."
          : "Tienes una nueva interacción.",
      };

    default:
      return null;
  }
}

serve(async (req: Request) => {
  try {
    const payload = await req.json();
    const record = payload.record;
    // Supabase envía el nombre de la tabla en el payload del webhook
    const table: string = payload.table ?? "";

    const resolved = resolveNotification(table, record);

    if (!resolved) {
      console.log(`Tabla '${table}' no configurada para notificaciones.`);
      return new Response("Table not handled", { status: 200 });
    }

    const { receptorId, title, body } = resolved;

    if (!receptorId) {
      console.log("No se encontró receptor en el payload:", record);
      return new Response("No receptor found", { status: 400 });
    }

    // 1. Obtener Access Token de Google
    const accessToken = await getGoogleAccessToken();

    // 2. Buscar el token FCM del dispositivo del receptor
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { data: userData, error: userError } = await supabaseClient
      .from("fcm_tokens")
      .select("token")
      .eq("user_id", receptorId)
      .single();

    if (userError || !userData) {
      console.log(`Token FCM no encontrado para usuario: ${receptorId}. El usuario puede no tener la app.`);
      return new Response("Token not found", { status: 404 });
    }

    // 3. Enviar la notificación via Firebase Cloud Messaging API v1
    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: userData.token,
            notification: { title, body },
            data: { table, route: "/home" },
          },
        }),
      }
    );

    const result = await fcmRes.json();
    console.log("FCM response:", JSON.stringify(result));
    return new Response(JSON.stringify(result), { status: 200 });

  } catch (error) {
    const err = error as Error;
    console.error("Error en la función:", err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
});
