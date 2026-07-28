import 'package:tinysteps/Models/attendance_model.dart';

class AttendanceState {
  final bool loading;
  final String? error;
  final List<Map<String, dynamic>> children;
  final Map<String, AttendanceModel?> attendance;
  final Map<String, bool> saving;

  const AttendanceState({
    this.loading = false,
    this.error,
    this.children = const [],
    this.attendance = const {},
    this.saving = const {},
  });

  AttendanceState copyWith({
    bool? loading,
    String? error,
    List<Map<String, dynamic>>? children,
    Map<String, AttendanceModel?>? attendance,
    Map<String, bool>? saving,
  }) {
    return AttendanceState(
      loading: loading ?? this.loading,
      error: error,
      children: children ?? this.children,
      attendance: attendance ?? this.attendance,
      saving: saving ?? this.saving,
    );
  }
}
