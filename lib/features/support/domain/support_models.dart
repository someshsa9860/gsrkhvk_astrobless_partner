class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.category,
    required this.priority,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    this.messages = const [],
  });

  final String id;
  final String ticketNumber;
  final String category;
  final String priority;
  final String subject;
  final String description;
  final String status;
  final DateTime createdAt;
  final List<SupportMessage> messages;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final msgs = (json['messages'] as List<dynamic>?)
            ?.map((m) => SupportMessage.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];
    return SupportTicket(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      messages: msgs,
    );
  }

  bool get isOpen =>
      status == 'open' || status == 'inProgress' || status == 'waitingOnUser';
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.authorType,
    this.authorId,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String authorType;
  final String? authorId;
  final String body;
  final DateTime createdAt;

  factory SupportMessage.fromJson(Map<String, dynamic> json) =>
      SupportMessage(
        id: json['id'] as String,
        authorType: json['authorType'] as String,
        authorId: json['authorId'] as String?,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  bool get isFromAstrologer => authorType == 'astrologer';
}
