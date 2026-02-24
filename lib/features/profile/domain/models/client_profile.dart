class ClientProfile {
  const ClientProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final DateTime? createdAt;

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
