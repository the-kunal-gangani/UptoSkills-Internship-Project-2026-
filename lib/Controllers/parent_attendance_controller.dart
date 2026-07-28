import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class ParentAttendanceState {
  final bool isLoading;
  final List<dynamic> records;
  final String? errorMessage;

  const ParentAttendanceState({
    this.isLoading = true,
    this.records = const [],
    this.errorMessage,
  });

  ParentAttendanceState copyWith({
    bool? isLoading,
    List<dynamic>? records,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ParentAttendanceState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class ParentAttendanceController extends StateNotifier<ParentAttendanceState> {
  ParentAttendanceController() : super(const ParentAttendanceState()) {
    loadAttendance();
  }

  final _client = Supabase.instance.client;

  Future<void> loadAttendance() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        state = state.copyWith(isLoading: false, records: []);
        return;
      }

      final data = await _client
          .from('attendance')
          .select(
            'date, checked_in_at, checked_out_at, method, '
            'children!inner(full_name, parent_id)',
          )
          .eq('children.parent_id', uid)
          .order('date', ascending: false)
          .limit(50);

      state = state.copyWith(isLoading: false, records: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── Formatting helpers ────────────────────────────────────────────
  String formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      return DateFormat('EEE, d MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String formatTime(String? raw) {
    if (raw == null) return '—';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return '—';
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final parentAttendanceProvider =
    StateNotifierProvider<ParentAttendanceController, ParentAttendanceState>(
      (ref) => ParentAttendanceController(),
    );
