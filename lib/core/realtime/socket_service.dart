import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import '../../features/consultations/domain/consultation_models.dart';

enum SocketConnectionState { disconnected, connecting, connected }

class SocketService {
  io.Socket? _socket;

  final _incomingRequestCtrl = StreamController<IncomingRequest>.broadcast();
  final _newMessageCtrl = StreamController<ChatMessage>.broadcast();
  final _billingTickCtrl = StreamController<BillingTick>.broadcast();
  final _consultationEndedCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _callIncomingCtrl = StreamController<CallIncoming>.broadcast();
  final _callEndedCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionCtrl = StreamController<SocketConnectionState>.broadcast();
  final _lowBalanceCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<IncomingRequest> get onIncomingRequest => _incomingRequestCtrl.stream;
  Stream<ChatMessage> get onNewMessage => _newMessageCtrl.stream;
  Stream<BillingTick> get onBillingTick => _billingTickCtrl.stream;
  Stream<Map<String, dynamic>> get onConsultationEnded => _consultationEndedCtrl.stream;
  Stream<CallIncoming> get onCallIncoming => _callIncomingCtrl.stream;
  Stream<Map<String, dynamic>> get onCallEnded => _callEndedCtrl.stream;
  Stream<SocketConnectionState> get onConnectionChanged => _connectionCtrl.stream;
  Stream<Map<String, dynamic>> get onLowBalance => _lowBalanceCtrl.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String accessToken) {
    if (_socket?.connected == true) return;

    _connectionCtrl.add(SocketConnectionState.connecting);

    _socket = io.io(
      AppConfig.wsBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': accessToken})
          .enableAutoConnect()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] connected');
      _connectionCtrl.add(SocketConnectionState.connected);
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] disconnected');
      _connectionCtrl.add(SocketConnectionState.disconnected);
    });

    _socket!.onConnectError((e) {
      debugPrint('[Socket] connect error: $e');
      _connectionCtrl.add(SocketConnectionState.disconnected);
    });

    _socket!.on('consultation:requested', (data) {
      try {
        final map = _toMap(data);
        _incomingRequestCtrl.add(IncomingRequest.fromJson(map));
      } catch (e) {
        debugPrint('[Socket] consultation:requested parse error: $e');
      }
    });

    _socket!.on('message:new', (data) {
      try {
        final map = _toMap(data);
        final msg = map['message'] as Map<String, dynamic>? ?? map;
        _newMessageCtrl.add(ChatMessage.fromJson(msg));
      } catch (e) {
        debugPrint('[Socket] message:new parse error: $e');
      }
    });

    _socket!.on('billing:tick', (data) {
      try {
        _billingTickCtrl.add(BillingTick.fromJson(_toMap(data)));
      } catch (e) {
        debugPrint('[Socket] billing:tick parse error: $e');
      }
    });

    _socket!.on('consultation:ended', (data) {
      try {
        _consultationEndedCtrl.add(_toMap(data));
      } catch (e) {
        debugPrint('[Socket] consultation:ended parse error: $e');
      }
    });

    _socket!.on('call:incoming', (data) {
      try {
        _callIncomingCtrl.add(CallIncoming.fromJson(_toMap(data)));
      } catch (e) {
        debugPrint('[Socket] call:incoming parse error: $e');
      }
    });

    _socket!.on('call:ended', (data) {
      try {
        _callEndedCtrl.add(_toMap(data));
      } catch (e) {
        debugPrint('[Socket] call:ended parse error: $e');
      }
    });

    _socket!.on('billing:lowBalance', (data) {
      try {
        _lowBalanceCtrl.add(_toMap(data));
      } catch (e) {
        debugPrint('[Socket] billing:lowBalance parse error: $e');
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void acceptConsultation(String consultationId) {
    _socket?.emit('consultation:accept', {'consultationId': consultationId});
  }

  void rejectConsultation(String consultationId, {String reason = 'busy'}) {
    _socket?.emit('consultation:reject', {'consultationId': consultationId, 'reason': reason});
  }

  void sendMessage({
    required String consultationId,
    required String body,
    required String clientMsgId,
    String type = 'text',
    String? mediaUrl,
  }) {
    _socket?.emit('message:send', {
      'consultationId': consultationId,
      'type': type,
      'body': body,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      'clientMsgId': clientMsgId,
    });
  }

  void sendReadReceipt(String consultationId, String upToMessageId) {
    _socket?.emit('message:read', {
      'consultationId': consultationId,
      'upToMessageId': upToMessageId,
    });
  }

  void sendTypingStart(String consultationId) {
    _socket?.emit('typing:start', {'consultationId': consultationId});
  }

  void sendTypingStop(String consultationId) {
    _socket?.emit('typing:stop', {'consultationId': consultationId});
  }

  void dispose() {
    disconnect();
    _incomingRequestCtrl.close();
    _newMessageCtrl.close();
    _billingTickCtrl.close();
    _consultationEndedCtrl.close();
    _callIncomingCtrl.close();
    _callEndedCtrl.close();
    _connectionCtrl.close();
    _lowBalanceCtrl.close();
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(service.dispose);
  return service;
});
