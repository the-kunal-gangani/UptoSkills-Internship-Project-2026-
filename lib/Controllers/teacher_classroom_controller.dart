import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class TeacherClassroomState {
  final bool isLoading;
  final List<Map<String, dynamic>> classrooms;
  final String? errorMessage;

  const TeacherClassroomState({
    this.isLoading = true,
    this.classrooms = const [],
    this.errorMessage,
  });

  TeacherClassroomState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? classrooms,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TeacherClassroomState(
      isLoading: isLoading ?? this.isLoading,
      classrooms: classrooms ?? this.classrooms,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class TeacherClassroomController
    extends StateNotifier<TeacherClassroomState> {
  TeacherClassroomController()
      : super(const TeacherClassroomState()) {
    loadClassrooms();
  }

  final _client = Supabase.instance.client;

  Future<void> loadClassrooms() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        state = state.copyWith(isLoading: false, classrooms: []);
        return;
      }
      final data = await _client
          .from('classrooms')
          .select('*')
          .eq('teacher_id', uid)
          .order('name');
      state = state.copyWith(
        isLoading: false,
        classrooms: List<Map<String, dynamic>>.from(data),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final teacherClassroomProvider = StateNotifierProvider<
    TeacherClassroomController, TeacherClassroomState>(
  (ref) => TeacherClassroomController(),
);