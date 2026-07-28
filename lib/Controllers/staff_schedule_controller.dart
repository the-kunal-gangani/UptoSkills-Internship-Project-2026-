import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class StaffScheduleState {
  final List<Map<String, dynamic>> sessions;
  final bool isLoading;
  final Set<String> actionInProgress; // session IDs being updated
  final String? error;

  const StaffScheduleState({
    this.sessions = const [],
    this.isLoading = false,
    this.actionInProgress = const {},
    this.error,
  });

  StaffScheduleState copyWith({
    List<Map<String, dynamic>>? sessions,
    bool? isLoading,
    Set<String>? actionInProgress,
    String? error,
  }) =>
      StaffScheduleState(
        sessions: sessions ?? this.sessions,
        isLoading: isLoading ?? this.isLoading,
        actionInProgress: actionInProgress ?? this.actionInProgress,
        error: error,
      );

  /// Returns sessions scheduled on a given date.
  List<Map<String, dynamic>> sessionsForDate(DateTime date) {
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}'
        '-${date.day.toString().padLeft(2, '0')}';
    return sessions
        .where((s) => (s['scheduled_date'] as String?) == key)
        .toList();
  }

  /// Today's next upcoming or in-progress session.
  Map<String, dynamic>? get todayNext {
    final today = DateTime.now().toIso8601String().split('T').first;
    final todayList = sessions
        .where((s) =>
            s['scheduled_date'] == today &&
            (s['status'] == 'confirmed' || s['status'] == 'in_progress'))
        .toList();
    if (todayList.isEmpty) return null;
    todayList.sort((a, b) =>
        (a['scheduled_start'] as String).compareTo(b['scheduled_start'] as String));
    return todayList.first;
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class StaffScheduleController extends StateNotifier<StaffScheduleState> {
  StaffScheduleController() : super(const StaffScheduleState()) {
    loadSchedule();
  }

  final _db = Supabase.instance.client;
  String? get _uid => _db.auth.currentUser?.id;

  static const _select = '''
    *,
    parents(id, full_name, email, phone, address),
    session_children(child_id, children(id, full_name, avatar_url, allergies))
  ''';

  Future<void> loadSchedule() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _db
          .from('sessions')
          .select(_select)
          .eq('staff_id', _uid!)
          .not('status', 'eq', 'cancelled')
          .order('scheduled_date')
          .order('scheduled_start');

      state = state.copyWith(
        sessions: List<Map<String, dynamic>>.from(data),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> startSession(String sessionId) async {
    state = state.copyWith(
      actionInProgress: {...state.actionInProgress, sessionId},
    );
    try {
      await _db.from('sessions').update({
        'actual_start_at': DateTime.now().toIso8601String(),
        'status': 'in_progress',
      }).eq('id', sessionId).eq('staff_id', _uid!);
      await loadSchedule();
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(
        actionInProgress: state.actionInProgress..remove(sessionId),
      );
    }
  }

  Future<bool> endSession(String sessionId) async {
    state = state.copyWith(
      actionInProgress: {...state.actionInProgress, sessionId},
    );
    try {
      await _db.from('sessions').update({
        'actual_end_at': DateTime.now().toIso8601String(),
        'status': 'completed',
      }).eq('id', sessionId).eq('staff_id', _uid!);
      await loadSchedule();
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(
        actionInProgress: state.actionInProgress..remove(sessionId),
      );
    }
  }

  Future<bool> triggerSosAlert(String sessionId, {String type = 'sos', String notes = 'Caregiver triggered SOS'}) async {
    try {
      await _db.from('alerts').insert({
        'session_id': sessionId,
        'sender_id': _uid!,
        'type': type,
        'notes': notes,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

final staffScheduleProvider =
    StateNotifierProvider<StaffScheduleController, StaffScheduleState>(
  (_) => StaffScheduleController(),
);
