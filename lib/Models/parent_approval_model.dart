class ParentApprovalModel {
final String id;
final String fullName;
final String email;
final String phone;
final String? address;
final String approvalStatus;
final DateTime? createdAt;
final DateTime? approvedAt;
final String? approvedBy;

const ParentApprovalModel({
required this.id,
required this.fullName,
required this.email,
required this.phone,
this.address,
required this.approvalStatus,
this.createdAt,
this.approvedAt,
this.approvedBy,
});

factory ParentApprovalModel.fromJson(
Map<String, dynamic> json,
) {
return ParentApprovalModel(
id: json['id'],
fullName: json['full_name'] ?? '',
email: json['email'] ?? '',
phone: json['phone'] ?? '',
address: json['address'],
approvalStatus:
json['approval_status'] ?? 'pending',
createdAt: json['created_at'] != null
? DateTime.parse(json['created_at'])
: null,
approvedAt: json['approved_at'] != null
? DateTime.parse(json['approved_at'])
: null,
approvedBy: json['approved_by'],
);
}
}
