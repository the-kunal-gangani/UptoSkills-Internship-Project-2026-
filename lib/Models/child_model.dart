class ChildModel {
  final String name;
  final String dob;
  final String gender;
  final String? allergies;
  final String? medicalNotes;
  final String? classroomCode;

  const ChildModel({
    required this.name,
    required this.dob,
    required this.gender,
    this.allergies,
    this.medicalNotes,
    this.classroomCode,
  });

  Map<String, dynamic> toMetadata() {
    return {
      'child_name': name,
      'child_dob': dob,
      'child_gender': gender,
      if (allergies != null && allergies!.isNotEmpty)
        'child_allergies': allergies,
      if (medicalNotes != null && medicalNotes!.isNotEmpty)
        'child_medical_notes': medicalNotes,
      if (classroomCode != null && classroomCode!.isNotEmpty)
        'child_classroom_code': classroomCode!.toUpperCase(),
    };
  }
}
