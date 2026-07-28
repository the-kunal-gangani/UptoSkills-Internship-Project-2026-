class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? referralCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? relationship;
  final String? staffId;
  final String? designation;
  final String? centerName;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.referralCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.relationship,
    this.staffId,
    this.designation,
    this.centerName,
  });

  Map<String, dynamic> toMetadata() {
    return {
      'full_name': fullName,
      'role': role,
      'phone': phone,
      if (referralCode != null && referralCode!.isNotEmpty)
        'referral_code': referralCode,
      if (emergencyContactName != null)
        'emergency_contact_name': emergencyContactName,
      if (emergencyContactPhone != null)
        'emergency_contact_phone': emergencyContactPhone,
      if (relationship != null) 'relationship': relationship,
      if (staffId != null && staffId!.isNotEmpty) 'staff_id': staffId,
      if (designation != null) 'designation': designation,
      if (centerName != null && centerName!.isNotEmpty)
        'center_name': centerName,
    };
  }

  factory UserModel.fromMetadata(
      String id, String email, Map<String, dynamic> meta) {
    return UserModel(
      id: id,
      email: email,
      fullName: meta['full_name'] as String? ?? '',
      phone: meta['phone'] as String? ?? '',
      role: meta['role'] as String? ?? 'parent',
      referralCode: meta['referral_code'] as String?,
      emergencyContactName: meta['emergency_contact_name'] as String?,
      emergencyContactPhone: meta['emergency_contact_phone'] as String?,
      relationship: meta['relationship'] as String?,
      staffId: meta['staff_id'] as String?,
      designation: meta['designation'] as String?,
      centerName: meta['center_name'] as String?,
    );
  }
}