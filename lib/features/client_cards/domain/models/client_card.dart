import 'dart:convert';

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

  /// Identifier shown to cashiers when QR scanning is unavailable.
  String get displayId {
    final normalizedCardUid = _normalizeIdentifier(cardUid);
    if (normalizedCardUid.isNotEmpty) {
      return normalizedCardUid;
    }

    final normalizedMembershipId = _normalizeIdentifier(membershipId);
    if (normalizedMembershipId.isNotEmpty) {
      return normalizedMembershipId;
    }

    final normalizedCompanyId = _normalizeIdentifier(companyId);
    return normalizedCompanyId;
  }

  /// Safe payload used for rendering QR in app.
  /// Falls back to card id when API payload is empty/invalid/too large.
  String get qrDataForDisplay {
    final normalizedPayload = _normalizeQrPayload(qrPayload);
    if (normalizedPayload.isNotEmpty &&
        _isWithinQrByteLimit(normalizedPayload)) {
      return normalizedPayload;
    }

    return displayId;
  }

  factory ClientCard.fromJson(Map<String, dynamic> json) {
    return ClientCard(
      membershipId: (json['membership_id'] ?? '').toString(),
      companyId: (json['company_id'] ?? '').toString(),
      companyName: (json['company_name'] ?? '').toString(),
      cardUid: (json['card_uid'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      qrPayload: _asQrPayload(json['qr_payload']),
      pointsBalance: _asInt(json['points_balance']),
      branding: CardBranding.fromJson(_asMap(json['branding'])),
    );
  }

  static const int _maxQrByteLength = 2953;

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

  static String _asQrPayload(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    if (value is Map || value is List) {
      try {
        return jsonEncode(value);
      } catch (_) {
        return value.toString();
      }
    }

    return value.toString();
  }

  static String _normalizeIdentifier(String value) {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty || normalizedValue.toLowerCase() == 'null') {
      return '';
    }

    return normalizedValue;
  }

  static String _normalizeQrPayload(String value) {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty || normalizedValue.toLowerCase() == 'null') {
      return '';
    }

    return normalizedValue;
  }

  static bool _isWithinQrByteLimit(String value) {
    return utf8.encode(value).length <= _maxQrByteLength;
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
