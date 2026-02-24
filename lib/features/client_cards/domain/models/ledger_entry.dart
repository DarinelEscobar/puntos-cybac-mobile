class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.membershipId,
    required this.type,
    required this.pointsDelta,
    required this.purchaseAmountMxn,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String membershipId;
  final String type;
  final int pointsDelta;
  final double? purchaseAmountMxn;
  final String? note;
  final DateTime? createdAt;

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: (json['id'] ?? '').toString(),
      membershipId: (json['membership_id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      pointsDelta: _asInt(json['points_delta']),
      purchaseAmountMxn: _asDouble(json['purchase_amount_mxn']),
      note: json['note']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double? _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
