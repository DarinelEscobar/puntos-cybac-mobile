class Membership {
  const Membership({
    required this.id,
    required this.companyId,
    required this.status,
    required this.cardUid,
    required this.pointsBalance,
    required this.createdAt,
  });

  final String id;
  final String companyId;
  final String status;
  final String cardUid;
  final int pointsBalance;
  final DateTime? createdAt;

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: (json['id'] ?? '').toString(),
      companyId: (json['company_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      cardUid: (json['card_uid'] ?? '').toString(),
      pointsBalance: _asInt(json['points_balance_cached']),
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
}
