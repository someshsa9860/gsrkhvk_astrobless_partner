class Consultation {
  const Consultation({
    required this.id,
    required this.customerName,
    required this.type,
    required this.status,
    required this.pricePerMinPaise,
    required this.requestedAt,
    this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.totalChargedPaise = 0,
    this.astrologerEarningPaise = 0,
    this.customerProfileUrl,
    this.endReason,
  });

  final String id;
  final String customerName;
  final String type;   // chat | voice | video | kundli
  final String status; // requested | accepted | active | ended | rejected | cancelled
  final int pricePerMinPaise;
  final DateTime requestedAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final int totalChargedPaise;
  final int astrologerEarningPaise;
  final String? customerProfileUrl;
  final String? endReason;

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String,
      customerName: json['customerName'] as String? ?? 'Customer',
      type: json['type'] as String,
      status: json['status'] as String,
      pricePerMinPaise: json['pricePerMinPaise'] as int,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt'] as String) : null,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      totalChargedPaise: json['totalChargedPaise'] as int? ?? 0,
      astrologerEarningPaise: json['astrologerEarningPaise'] as int? ?? 0,
      customerProfileUrl: json['customerProfileUrl'] as String?,
      endReason: json['endReason'] as String?,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.consultationId,
    required this.senderType,
    required this.body,
    required this.createdAt,
    this.type = 'text',
    this.mediaUrl,
    this.clientMsgId,
  });

  final String id;
  final String consultationId;
  final String senderType; // customer | astrologer | system
  final String body;
  final DateTime createdAt;
  final String type;
  final String? mediaUrl;
  final String? clientMsgId;

  bool get isFromMe => senderType == 'astrologer';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      consultationId: json['consultationId'] as String? ?? '',
      senderType: json['senderType'] as String,
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: json['type'] as String? ?? 'text',
      mediaUrl: json['mediaUrl'] as String?,
      clientMsgId: json['clientMsgId'] as String?,
    );
  }

  ChatMessage copyWith({String? id, String? clientMsgId}) {
    return ChatMessage(
      id: id ?? this.id,
      consultationId: consultationId,
      senderType: senderType,
      body: body,
      createdAt: createdAt,
      type: type,
      mediaUrl: mediaUrl,
      clientMsgId: clientMsgId ?? this.clientMsgId,
    );
  }
}

class IncomingRequest {
  const IncomingRequest({
    required this.consultationId,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.pricePerMinPaise,
    this.customerProfileUrl,
  });

  final String consultationId;
  final String customerId;
  final String customerName;
  final String type; // chat | voice | video
  final int pricePerMinPaise;
  final String? customerProfileUrl;

  factory IncomingRequest.fromJson(Map<String, dynamic> json) {
    return IncomingRequest(
      consultationId: json['consultationId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String? ?? 'Customer',
      type: json['type'] as String? ?? 'chat',
      pricePerMinPaise: json['pricePerMinPaise'] as int? ?? 0,
      customerProfileUrl: json['customerProfileUrl'] as String?,
    );
  }
}

class BillingTick {
  const BillingTick({
    required this.consultationId,
    required this.remainingSeconds,
    required this.balancePaise,
  });

  final String consultationId;
  final int remainingSeconds;
  final int balancePaise;

  factory BillingTick.fromJson(Map<String, dynamic> json) {
    return BillingTick(
      consultationId: json['consultationId'] as String,
      remainingSeconds: json['remainingSeconds'] as int,
      balancePaise: json['balancePaise'] as int,
    );
  }
}

class CallIncoming {
  const CallIncoming({
    required this.consultationId,
    required this.agoraToken,
    required this.channelName,
    required this.type,
    required this.customerName,
    this.customerProfileUrl,
  });

  final String consultationId;
  final String agoraToken;
  final String channelName;
  final String type; // voice | video
  final String customerName;
  final String? customerProfileUrl;

  factory CallIncoming.fromJson(Map<String, dynamic> json) {
    return CallIncoming(
      consultationId: json['consultationId'] as String,
      agoraToken: json['agoraToken'] as String,
      channelName: json['channelName'] as String,
      type: json['type'] as String? ?? 'voice',
      customerName: json['customerName'] as String? ?? 'Customer',
      customerProfileUrl: json['customerProfileUrl'] as String?,
    );
  }
}
