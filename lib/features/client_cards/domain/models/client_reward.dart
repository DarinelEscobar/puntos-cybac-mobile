class ClientReward {
  const ClientReward({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.pointsCost,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String companyId;
  final String name;
  final String type;
  final int pointsCost;
  final bool isActive;
  final DateTime? createdAt;

  factory ClientReward.fromJson(Map<String, dynamic> json) {
    return ClientReward(
      id: (json['id'] ?? '').toString(),
      companyId: (json['company_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      pointsCost: _asInt(json['points_cost']),
      isActive: _asBool(json['is_active']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
}
