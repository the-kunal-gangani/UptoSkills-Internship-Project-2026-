// ─────────────────────────────────────────────────────────────────────────────
// SessionBookingModel
// Maps to: session_bookings table in Supabase
// ─────────────────────────────────────────────────────────────────────────────

class SessionBookingModel {
  final String id;
  final String parentId;
  final String childId;
  final String teacherId;
  final DateTime sessionDate;
  final String startTime; // 'HH:MM:SS'
  final String endTime;   // 'HH:MM:SS'
  final String status;    // 'pending' | 'confirmed' | 'cancelled'
  final String? notes;
  final DateTime createdAt;

  // Joined fields (optional, filled when using SELECT with joins)
  final String? teacherName;
  final String? teacherDesignation;
  final String? childName;
  final String? parentName;

  const SessionBookingModel({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.teacherId,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
    this.teacherName,
    this.teacherDesignation,
    this.childName,
    this.parentName,
  });

  factory SessionBookingModel.fromMap(Map<String, dynamic> map) {
    // Handle joined teacher data
    final teacher = map['teachers'] as Map<String, dynamic>?;
    final child = map['children'] as Map<String, dynamic>?;
    final parent = map['parents'] as Map<String, dynamic>?;

    return SessionBookingModel(
      id: map['id'] as String,
      parentId: map['parent_id'] as String,
      childId: map['child_id'] as String,
      teacherId: map['teacher_id'] as String,
      sessionDate: DateTime.parse(map['session_date'] as String),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      status: map['status'] as String? ?? 'pending',
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      teacherName: teacher?['full_name'] as String?,
      teacherDesignation: teacher?['designation'] as String?,
      childName: child?['full_name'] as String?,
      parentName: parent?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'parent_id': parentId,
        'child_id': childId,
        'teacher_id': teacherId,
        'session_date': '${sessionDate.year}-${sessionDate.month.toString().padLeft(2, '0')}-${sessionDate.day.toString().padLeft(2, '0')}',
        'start_time': startTime,
        'end_time': endTime,
        'status': status,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  SessionBookingModel copyWith({
    String? id,
    String? parentId,
    String? childId,
    String? teacherId,
    DateTime? sessionDate,
    String? startTime,
    String? endTime,
    String? status,
    String? notes,
    DateTime? createdAt,
    String? teacherName,
    String? teacherDesignation,
    String? childName,
    String? parentName,
  }) =>
      SessionBookingModel(
        id: id ?? this.id,
        parentId: parentId ?? this.parentId,
        childId: childId ?? this.childId,
        teacherId: teacherId ?? this.teacherId,
        sessionDate: sessionDate ?? this.sessionDate,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        teacherName: teacherName ?? this.teacherName,
        teacherDesignation: teacherDesignation ?? this.teacherDesignation,
        childName: childName ?? this.childName,
        parentName: parentName ?? this.parentName,
      );

  /// Formats the date as 'DD MMM YYYY'
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${sessionDate.day} ${months[sessionDate.month - 1]} ${sessionDate.year}';
  }

  /// Formats time as '09:00 AM'
  String get formattedStartTime {
    final parts = startTime.split(':');
    if (parts.length < 2) return startTime;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1].padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  String get formattedEndTime {
    final parts = endTime.split(':');
    if (parts.length < 2) return endTime;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1].padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';

  @override
  String toString() =>
      'SessionBookingModel(id: $id, date: $formattedDate, $startTime–$endTime, status: $status)';
}
