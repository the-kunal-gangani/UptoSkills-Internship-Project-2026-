class ReferralCodeModel {
  final String id;
  final String code;
  final String role;
  final bool isUsed;
  final bool isActive;
  final String? usedBy;
  final DateTime? usedAt;
  final DateTime? expiresAt;
  final String? createdBy;
  final DateTime? createdAt;

  const ReferralCodeModel({
    required this.id,
    required this.code,
    required this.role,
    required this.isUsed,
    required this.isActive,
    this.usedBy,
    this.usedAt,
    this.expiresAt,
    this.createdBy,
    this.createdAt,
  });

  factory ReferralCodeModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return ReferralCodeModel(
      id: map['id']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      role: map['role']?.toString() ?? 'teacher',
      isUsed: map['is_used'] == true,
      isActive: map['is_active'] != false,
      usedBy: map['used_by']?.toString(),
      usedAt: parseDateTime(map['used_at']),
      expiresAt: parseDateTime(map['expires_at']),
      createdBy: map['created_by']?.toString(),
      createdAt: parseDateTime(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'role': role,
      'is_used': isUsed,
      'is_active': isActive,
      'used_by': usedBy,
      'used_at': usedAt?.toUtc().toIso8601String(),
      'expires_at': expiresAt?.toUtc().toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt?.toUtc().toIso8601String(),
    };
  }
}
