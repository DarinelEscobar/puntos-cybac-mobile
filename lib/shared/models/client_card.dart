class ClientCard {
  const ClientCard({
    required this.membershipId,
    required this.companyId,
    required this.companyName,
    required this.cardUid,
    required this.status,
    required this.qrPayload,
    required this.pointsBalance,
    required this.branding,
  });

  final String membershipId;
  final String companyId;
  final String companyName;
  final String cardUid;
  final String status;
  final String qrPayload;
  final int pointsBalance;
  final CardBranding branding;

  factory ClientCard.fromJson(Map<String, dynamic> json) {
    return ClientCard(
      membershipId: (json['membership_id'] ?? '').toString(),
      companyId: (json['company_id'] ?? '').toString(),
      companyName: (json['company_name'] ?? '').toString(),
      cardUid: (json['card_uid'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      qrPayload: (json['qr_payload'] ?? '').toString(),
      pointsBalance: _asInt(json['points_balance']),
      branding: CardBranding.fromJson(_asMap(json['branding'])),
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

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }

    return <String, dynamic>{};
  }
}

class CardBranding {
  const CardBranding({
    required this.logoUrl,
    required this.colorPrimary,
    required this.colorSecondary,
    required this.colorAccent,
  });

  final String? logoUrl;
  final String? colorPrimary;
  final String? colorSecondary;
  final String? colorAccent;

  factory CardBranding.fromJson(Map<String, dynamic> json) {
    return CardBranding(
      logoUrl: _asNullableString(json['logo_url']),
      colorPrimary: _asNullableString(json['color_primary']),
      colorSecondary: _asNullableString(json['color_secondary']),
      colorAccent: _asNullableString(json['color_accent']),
    );
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final stringValue = value.toString().trim();
    if (stringValue.isEmpty || stringValue.toLowerCase() == 'null') {
      return null;
    }

    return stringValue;
  }
}
