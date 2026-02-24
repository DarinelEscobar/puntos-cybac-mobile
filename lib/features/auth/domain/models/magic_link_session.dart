class MagicLinkSession {
  const MagicLinkSession({
    required this.accessToken,
    required this.tokenType,
    required this.defaultMembershipId,
  });

  final String accessToken;
  final String tokenType;
  final String? defaultMembershipId;
}
