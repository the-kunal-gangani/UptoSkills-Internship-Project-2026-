// ─────────────────────────────────────────────────────────────────────────────
// TeacherLeaveModel
// Maps to: teacher_leave table in Supabase
// ─────────────────────────────────────────────────────────────────────────────

class TeacherLeaveModel {
  final String id;
  final String teacherId;
  final DateTime leaveDate;
  final String reason;
  final String leaveType; // 'leave' | 'holiday'
  final DateTime createdAt;

  const TeacherLeaveModel({
    required this.id,
    required this.teacherId,
    required this.leaveDate,
    required this.reason,
    required this.leaveType,
    required this.createdAt,
  });

  factory TeacherLeaveModel.fromMap(Map<String, dynamic> map) {
    return TeacherLeaveModel(
      id: map['id'] as String,
      teacherId: map['teacher_id'] as String,
      leaveDate: DateTime.parse(map['leave_date'] as String),
      reason: map['reason'] as String? ?? '',
      leaveType: map['leave_type'] as String? ?? 'leave',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'teacher_id': teacherId,
        'leave_date': '${leaveDate.year}-${leaveDate.month.toString().padLeft(2, '0')}-${leaveDate.day.toString().padLeft(2, '0')}',
        'reason': reason,
        'leave_type': leaveType,
      };

  TeacherLeaveModel copyWith({
    String? id,
    String? teacherId,
    DateTime? leaveDate,
    String? reason,
    String? leaveType,
    DateTime? createdAt,
  }) =>
      TeacherLeaveModel(
        id: id ?? this.id,
        teacherId: teacherId ?? this.teacherId,
        leaveDate: leaveDate ?? this.leaveDate,
        reason: reason ?? this.reason,
        leaveType: leaveType ?? this.leaveType,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Formats the date as 'DD MMM YYYY'
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${leaveDate.day} ${months[leaveDate.month - 1]} ${leaveDate.year}';
  }

  bool get isHoliday => leaveType == 'holiday';

  @override
  String toString() =>
      'TeacherLeaveModel(id: $id, date: $formattedDate, type: $leaveType)';
}
