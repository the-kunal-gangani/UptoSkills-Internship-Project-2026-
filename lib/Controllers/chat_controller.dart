import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessage {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderRole;
  final String body;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderRole,
    required this.body,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      senderId: json['sender_id'] as String,
      senderRole: json['sender_role'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSessionActive;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSessionActive = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSessionActive,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      error: error,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final String sessionId;
  ChatController(this.sessionId) : super(ChatState()) {
    checkSessionActivity();
    fetchMessages();
    _subscribeToChannel();
  }

  final _db = Supabase.instance.client;
  RealtimeChannel? _channel;

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> checkSessionActivity() async {
    try {
      final data = await _db
          .from('sessions')
          .select('status, scheduled_date, scheduled_start, scheduled_end')
          .eq('id', sessionId)
          .single();

      final status = data['status'] as String;
      if (status == 'in_progress') {
        state = state.copyWith(isSessionActive: true);
        return;
      }

      // Check time window (+/- 1 hour of scheduled window)
      final dateStr = data['scheduled_date'] as String;
      final startStr = data['scheduled_start'] as String;
      final endStr = data['scheduled_end'] as String;

      final startParts = startStr.split(':');
      final endParts = endStr.split(':');

      final date = DateTime.parse(dateStr);
      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );
      final endTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      final now = DateTime.now();
      final oneHour = const Duration(hours: 1);

      final isWithinWindow = now.isAfter(startTime.subtract(oneHour)) &&
          now.isBefore(endTime.add(oneHour));

      state = state.copyWith(isSessionActive: isWithinWindow);
    } catch (_) {
      state = state.copyWith(isSessionActive: false);
    }
  }

  Future<void> fetchMessages() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _db
          .from('messages')
          .select()
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);

      final list = (res as List<dynamic>)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();

      state = state.copyWith(messages: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _subscribeToChannel() {
    _channel = _db
        .channel('public:messages:session_$sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            if (payload.newRecord['session_id'] != sessionId) return;
            final newMessage = ChatMessage.fromJson(payload.newRecord);
            // Deduplicate incoming realtime messages
            if (!state.messages.any((m) => m.id == newMessage.id)) {
              state = state.copyWith(
                messages: [...state.messages, newMessage],
              );
            }
          },
        )
        .subscribe();
  }

  Future<bool> sendMessage(String text) async {
    if (text.trim().isEmpty) return false;
    final user = _db.auth.currentUser;
    if (user == null) return false;

    final role = user.userMetadata?['role'] as String? ?? 'parent';
    final senderRole = role == 'teacher' ? 'staff' : (role == 'admin' ? 'admin' : 'parent');

    try {
      await _db.from('messages').insert({
        'session_id': sessionId,
        'sender_id': user.id,
        'sender_role': senderRole,
        'body': text.trim(),
      });
      return true;
    } catch (e) {
      debugPrint('[Chat] Failed to send message: $e');
      return false;
    }
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatController, ChatState, String>(
  (ref, sessionId) => ChatController(sessionId),
);
