import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class TeacherHomeState {
  final bool? isApproved; // null = still checking
  final bool isLoadingAttendance;
  final bool isLoadingChildren;
  final List<dynamic> todayAttendance;
  final List<dynamic> children;
  final String? errorMessage;

  const TeacherHomeState({
    this.isApproved,
    this.isLoadingAttendance = false,
    this.isLoadingChildren = false,
    this.todayAttendance = const [],
    this.children = const [],
    this.errorMessage,
  });

  TeacherHomeState copyWith({
    bool? isApproved,
    bool setApprovedNull = false,
    bool? isLoadingAttendance,
    bool? isLoadingChildren,
    List<dynamic>? todayAttendance,
    List<dynamic>? children,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TeacherHomeState(
      isApproved: setApprovedNull ? null : isApproved ?? this.isApproved,
      isLoadingAttendance: isLoadingAttendance ?? this.isLoadingAttendance,
      isLoadingChildren: isLoadingChildren ?? this.isLoadingChildren,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      children: children ?? this.children,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class TeacherHomeController extends StateNotifier<TeacherHomeState> {
  TeacherHomeController() : super(const TeacherHomeState()) {
    checkApproval();
  }

  final _client = Supabase.instance.client;

  String get teacherName =>
      _client.auth.currentUser?.userMetadata?['full_name'] as String? ??
      'Staff';

  // ── Approval check ────────────────────────────────────────────────
  Future<void> checkApproval() async {
    state = state.copyWith(setApprovedNull: true);
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      state = state.copyWith(isApproved: false);
      return;
    }
    try {
      final row = await _client
          .from('teachers')
          .select('is_approved, is_active')
          .eq('id', uid)
          .maybeSingle();
      state = state.copyWith(
        isApproved:
            row != null &&
            row['is_approved'] == true &&
            row['is_active'] == true,
      );
      if (state.isApproved == true) {
        loadTodayAttendance();
        loadChildren();
      }
    } catch (_) {
      state = state.copyWith(isApproved: false);
    }
  }

  // ── Today's attendance ────────────────────────────────────────────
  Future<void> loadTodayAttendance() async {
    state = state.copyWith(isLoadingAttendance: true);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final uid = _client.auth.currentUser?.id ?? '';
    try {
      final data = await _client
          .from('attendance')
          .select(
            'child_id, checked_in_at, checked_out_at, '
            'children!inner(full_name, teacher_id)',
          )
          .eq('date', today)
          .eq('children.teacher_id', uid);
      state = state.copyWith(isLoadingAttendance: false, todayAttendance: data);
    } catch (_) {
      state = state.copyWith(isLoadingAttendance: false);
    }
  }

  // ── Children ──────────────────────────────────────────────────────
  Future<void> loadChildren() async {
    state = state.copyWith(isLoadingChildren: true);
    final uid = _client.auth.currentUser?.id ?? '';
    try {
      final data = await _client
          .from('children')
          .select('id, full_name, date_of_birth, gender, allergies, status')
          .eq('teacher_id', uid)
          .order('full_name');
      state = state.copyWith(isLoadingChildren: false, children: data);
    } catch (_) {
      state = state.copyWith(isLoadingChildren: false);
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────────
  String calcAge(String dob) {
    try {
      final birth = DateTime.parse(dob);
      final now = DateTime.now();
      int years = now.year - birth.year;
      int months = now.month - birth.month;
      if (now.day < birth.day) months--;
      if (months < 0) {
        years--;
        months += 12;
      }
      if (years > 0) return '$years yr${years > 1 ? 's' : ''}';
      return '$months month${months != 1 ? 's' : ''}';
    } catch (_) {
      return '';
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
final teacherHomeProvider =
    StateNotifierProvider<TeacherHomeController, TeacherHomeState>(
      (ref) => TeacherHomeController(),
    );
