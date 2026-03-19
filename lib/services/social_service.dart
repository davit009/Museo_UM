import 'package:supabase_flutter/supabase_flutter.dart';

class SocialService {
  final _client = Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  // 1. Enviar solicitud de conexión
  Future<void> sendConnectionRequest(String addresseeId) async {
    if (currentUserId == null) throw Exception('No autenticado');
    
    // Check if one already exists
    final exist = await _client.from('connections')
      .select('id')
      .or('and(requester_id.eq.$currentUserId,addressee_id.eq.$addresseeId),and(requester_id.eq.$addresseeId,addressee_id.eq.$currentUserId)')
      .maybeSingle();
      
    if (exist != null) {
      throw Exception('Ya existe una solicitud o conexión previa.');
    }

    await _client.from('connections').insert({
      'requester_id': currentUserId,
      'addressee_id': addresseeId,
      'status': 'pending',
    });
  }

  // 2. Aceptar/Rechazar solicitud
  Future<void> updateConnectionStatus(String connectionId, String status) async {
    await _client.from('connections').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', connectionId);
  }

  // 3. Enviar mensaje
  Future<void> sendMessage(String receiverId, String content) async {
    if (currentUserId == null) throw Exception('No autenticado');
    if (content.trim().isEmpty) return;

    await _client.from('restricted_messages').insert({
      'sender_id': currentUserId,
      'receiver_id': receiverId,
      'content': content.trim(),
    });
  }

  // 4. Leer Mensajes en Tiempo Real entre 2 personas
  Stream<List<Map<String, dynamic>>> getMessagesStream(String otherUserId) {
    if (currentUserId == null) return const Stream.empty();
    
    return _client
        .from('restricted_messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((messages) => messages.where((msg) => 
            (msg['sender_id'] == currentUserId && msg['receiver_id'] == otherUserId) ||
            (msg['sender_id'] == otherUserId && msg['receiver_id'] == currentUserId)
        ).toList());
  }

  // 5. Escuchar estado exacto de conexión (útil para el Botón)
  Stream<List<Map<String, dynamic>>> connectionStatusStream(String targetUserId) {
    if (currentUserId == null) return const Stream.empty();
    
    return _client.from('connections')
        .stream(primaryKey: ['id'])
        .map((connections) => connections.where((c) => 
            (c['requester_id'] == currentUserId && c['addressee_id'] == targetUserId) ||
            (c['requester_id'] == targetUserId && c['addressee_id'] == currentUserId)
        ).toList());
  }

  // 6. Buscar Perfiles
  Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    final uid = currentUserId;
    if (uid == null || query.trim().isEmpty) return [];
    final safeQuery = '%${query.trim()}%';
    
    final response = await _client
      .from('profiles')
      .select('id, username, nombre, matricula, carrera, generacion, biografia, avatar_url')
      .or('nombre.ilike.$safeQuery,matricula.ilike.$safeQuery')
      .neq('id', uid)
      .limit(20);
      
    return List<Map<String, dynamic>>.from(response);
  }

  // 7. Solicitudes Pendientes recibidas
  Stream<List<Map<String, dynamic>>> getPendingRequestsStream() {
    if (currentUserId == null) return const Stream.empty();
    
    return _client.from('connections')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((connections) => connections.where((c) => 
            c['addressee_id'] == currentUserId && c['status'] == 'pending'
        ).toList());
  }

  // 8. Conexiones Aceptadas
  Stream<List<Map<String, dynamic>>> getAcceptedConnectionsStream() {
    if (currentUserId == null) return const Stream.empty();
    
    return _client.from('connections')
        .stream(primaryKey: ['id'])
        .map((connections) => connections.where((c) => 
            c['status'] == 'accepted' &&
            (c['requester_id'] == currentUserId || c['addressee_id'] == currentUserId)
        ).toList());
  }

  // 9. Obtener Perfil por ID
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  // 10. Bloquear Usuario
  Future<void> blockUser(String targetId) async {
    if (currentUserId == null) return;
    final uid = currentUserId!;
    
    // 1. Registrar bloqueo
    await _client.from('blocks').insert({
      'blocker_id': uid,
      'blocked_id': targetId,
    });

    // 2. Destruir cualquier conexión existente (A o B)
    await _client.from('connections')
        .delete()
        .or('and(requester_id.eq.$uid,addressee_id.eq.$targetId),and(requester_id.eq.$targetId,addressee_id.eq.$uid)');
        
    // (Opcional) Borrar mensajes. Con RLS estricto o ignorando a los bloqueados en la UI, no es estrictamente necesario, 
    // pero si se desea destrucción total:
    await _client.from('restricted_messages')
        .delete()
        .or('and(sender_id.eq.$uid,receiver_id.eq.$targetId),and(sender_id.eq.$targetId,receiver_id.eq.$uid)');
  }

  // 11. Eliminar Conexión (Amistad)
  Future<void> removeConnection(String targetId) async {
    if (currentUserId == null) return;
    final uid = currentUserId!;
    
    await _client.from('connections')
        .delete()
        .or('and(requester_id.eq.$uid,addressee_id.eq.$targetId),and(requester_id.eq.$targetId,addressee_id.eq.$uid)');
  }

  // 11. Obtener Lista de Usuarios Bloqueados
  Future<List<String>> getBlockedUsers() async {
    if (currentUserId == null) return [];
    final response = await _client
        .from('blocks')
        .select('blocked_id')
        .eq('blocker_id', currentUserId!);
    
    return List<String>.from((response as List).map((b) => b['blocked_id'].toString()));
  }
}
