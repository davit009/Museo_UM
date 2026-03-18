class Connection {
  final String id;
  final String requesterId;
  final String addresseeId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  Connection({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      requesterId: json['requester_id'],
      addresseeId: json['addressee_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
