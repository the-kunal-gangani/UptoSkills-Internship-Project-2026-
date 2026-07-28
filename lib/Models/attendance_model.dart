class AttendanceModel {
  final String id;
  final String childId;
  final String? checkedInAt;
  final String? checkedOutAt;

  AttendanceModel({
    required this.id,
    required this.childId,
    this.checkedInAt,
    this.checkedOutAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      childId: json['child_id'] ?? '',
      checkedInAt: json['checked_in_at'],
      checkedOutAt: json['checked_out_at'],
    );
  }

  bool get isCheckedIn => checkedInAt != null;
  bool get isCheckedOut => checkedOutAt != null;
}
