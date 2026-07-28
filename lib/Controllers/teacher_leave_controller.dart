import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/Models/teacher_leave_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────
class TeacherLeaveState {
  final List<TeacherLeaveModel> leaves;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const TeacherLeaveState({
    this.leaves = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  TeacherLeaveState copyWith({
    List<TeacherLeaveModel>? leaves,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) =>
      TeacherLeaveState(
        leaves: leaves ?? this.leaves,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
      );

  /// Returns upcoming leave entries (today or in the future).
  List<TeacherLeaveModel> get upcomingLeaves {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return leaves
        .where((l) => !l.leaveDate.isBefore(todayDate))
        .toList()
      ..sort((a, b) => a.leaveDate.compareTo(b.leaveDate));
  }

  /// Returns past leave entries.
  List<TeacherLeaveModel> get pastLeaves {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return leaves
        .where((l) => l.leaveDate.isBefore(todayDate))
        .toList()
      ..sort((a, b) => b.leaveDate.compareTo(a.leaveDate));
  }

  /// Check if teacher is on leave on a given date.
  bool isOnLeave(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return leaves.any((l) {
      final ld = DateTime(l.leaveDate.year, l.leaveDate.month, l.leaveDate.day);
      return ld == dateOnly;
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────
class TeacherLeaveController extends StateNotifier<TeacherLeaveState> {
  TeacherLeaveController() : super(const TeacherLeaveState()) {
    loadLeaves();
  }

  final _db = Supabase.instance.client;
  String? get _uid => _db.auth.currentUser?.id;

  /// Loads all leave entries for the current teacher.
  Future<void> loadLeaves() async {
    if (_uid == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _db
          .from('teacher_leave')
          .select()
          .eq('teacher_id', _uid!)
          .order('leave_date');

      final leaves = (data as List)
          .map((e) => TeacherLeaveModel.fromMap(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(leaves: leaves, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Applies for a single leave day.
  Future<bool> applyLeave({
    required DateTime leaveDate,
    required String reason,
    String leaveType = 'leave',
  }) async {
    if (_uid == null) return false;
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final dateStr =
          '${leaveDate.year}-${leaveDate.month.toString().padLeft(2, '0')}-${leaveDate.day.toString().padLeft(2, '0')}';

      // Check if leave already exists for this date
      final existing = await _db
          .from('teacher_leave')
          .select('id')
          .eq('teacher_id', _uid!)
          .eq('leave_date', dateStr)
          .maybeSingle();

      if (existing != null) {
        state = state.copyWith(
          isSaving: false,
          error: 'Leave already applied for this date.',
        );
        return false;
      }

      await _db.from('teacher_leave').insert({
        'teacher_id': _uid!,
        'leave_date': dateStr,
        'reason': reason.trim(),
        'leave_type': leaveType,
      });

      await loadLeaves();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Cancels a leave entry.
  Future<bool> cancelLeave(String leaveId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _db
          .from('teacher_leave')
          .delete()
          .eq('id', leaveId)
          .eq('teacher_id', _uid!);

      await loadLeaves();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────
final teacherLeaveProvider =
    StateNotifierProvider<TeacherLeaveController, TeacherLeaveState>(
  (_) => TeacherLeaveController(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Public-facing provider: check if a specific teacher is on leave on a date
// Used by booking validation logic.
// ─────────────────────────────────────────────────────────────────────────────
final teacherLeaveDatesProvider =
    FutureProvider.family<List<DateTime>, String>(
  (ref, teacherId) async {
    final db = Supabase.instance.client;
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final data = await db
        .from('teacher_leave')
        .select('leave_date')
        .eq('teacher_id', teacherId)
        .gte('leave_date', todayStr)
        .order('leave_date');

    return (data as List)
        .map((e) => DateTime.parse(e['leave_date'] as String))
        .toList();
  },
);
