import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyAlert {
  final String id;
  final String sessionId;
  final String senderId;
  final String type;
  final String notes;
  final bool acknowledged;
  final DateTime createdAt;

  EmergencyAlert({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.type,
    required this.notes,
    required this.acknowledged,
    required this.createdAt,
  });

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      senderId: json['sender_id'] as String,
      type: json['type'] as String,
      notes: json['notes'] as String? ?? '',
      acknowledged: json['acknowledged'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}

class AlertState {
  final EmergencyAlert? activeAlert;
  final bool isListening;

  AlertState({this.activeAlert, this.isListening = false});

  AlertState copyWith({EmergencyAlert? activeAlert, bool? isListening}) {
    return AlertState(
      activeAlert: activeAlert ?? this.activeAlert,
      isListening: isListening ?? this.isListening,
    );
  }
}

class AlertController extends StateNotifier<AlertState> {
  AlertController() : super(AlertState()) {
    _startListening();
  }

  final _db = Supabase.instance.client;
  RealtimeChannel? _channel;

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _startListening() async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    final role = user.userMetadata?['role'] as String? ?? 'parent';
    
    // Set listening state
    state = state.copyWith(isListening: true);

    if (role == 'admin') {
      // ── Admin listens to ALL new alerts ───────────────────────────────────
      _channel = _db
          .channel('public:alerts:admin')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'alerts',
            callback: (payload) {
              final alert = EmergencyAlert.fromJson(payload.newRecord);
              if (!alert.acknowledged) {
                state = state.copyWith(activeAlert: alert);
              }
            },
          )
          .subscribe();
    } else if (role == 'parent') {
      // ── Parent listens to their own active session alerts ─────────────────
      // First, get parent's active sessions (pending/confirmed/in_progress)
      final mySessions = await _db
          .from('sessions')
          .select('id')
          .eq('parent_id', user.id)
          .or('status.eq.in_progress,status.eq.confirmed');

      final sessionIds = (mySessions as List<dynamic>)
          .map((s) => s['id'] as String)
          .toList();

      if (sessionIds.isEmpty) return;

      _channel = _db
          .channel('public:alerts:parent')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'alerts',
            callback: (payload) {
              final alert = EmergencyAlert.fromJson(payload.newRecord);
              if (sessionIds.contains(alert.sessionId) && !alert.acknowledged) {
                state = state.copyWith(activeAlert: alert);
              }
            },
          )
          .subscribe();
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    try {
      await _db
          .from('alerts')
          .update({'acknowledged': true, 'acknowledged_by': user.id})
          .eq('id', alertId);
      
      // Clear alert from state
      if (state.activeAlert?.id == alertId) {
        state = state.copyWith(activeAlert: null);
      }
    } catch (e) {
      debugPrint('[Alerts] Failed to acknowledge alert: $e');
    }
  }

  void dismissLocalAlert() {
    state = state.copyWith(activeAlert: null);
  }
}

final alertMonitorProvider =
    StateNotifierProvider<AlertController, AlertState>((_) => AlertController());
