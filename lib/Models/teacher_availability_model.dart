// ─────────────────────────────────────────────────────────────────────────────
// TeacherAvailabilityModel
// Maps to: teacher_availability table in Supabase
// ─────────────────────────────────────────────────────────────────────────────

class TeacherAvailabilityModel {
  final String id;
  final String teacherId;
  final int dayOfWeek; // 0 = Monday, 6 = Sunday
  final String startTime; // 'HH:MM:SS'
  final String endTime;   // 'HH:MM:SS'
  final String status;    // 'available' | 'break' | 'busy'
  final int maxSessionsPerDay;
  final DateTime createdAt;

  const TeacherAvailabilityModel({
    required this.id,
    required this.teacherId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.maxSessionsPerDay,
    required this.createdAt,
  });

  factory TeacherAvailabilityModel.fromMap(Map<String, dynamic> map) {
    return TeacherAvailabilityModel(
      id: map['id'] as String,
      teacherId: map['teacher_id'] as String,
      dayOfWeek: (map['day_of_week'] as num).toInt(),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      status: map['status'] as String? ?? 'available',
      maxSessionsPerDay: (map['max_sessions_per_day'] as num?)?.toInt() ?? 6,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'teacher_id': teacherId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'status': status,
        'max_sessions_per_day': maxSessionsPerDay,
      };

  TeacherAvailabilityModel copyWith({
    String? id,
    String? teacherId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? status,
    int? maxSessionsPerDay,
    DateTime? createdAt,
  }) =>
      TeacherAvailabilityModel(
        id: id ?? this.id,
        teacherId: teacherId ?? this.teacherId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
        maxSessionsPerDay: maxSessionsPerDay ?? this.maxSessionsPerDay,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Returns the day name for this availability slot.
  String get dayName => const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][dayOfWeek];

  /// Formats time as '09:00 AM'
  static String formatTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1].padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  String toString() =>
      'TeacherAvailabilityModel(id: $id, day: $dayName, $startTime–$endTime, status: $status)';
}
