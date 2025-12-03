class Referral {
  final int id;
  final String referralCode;
  final int invitedCount;

  Referral({
    required this.id,
    required this.referralCode,
    required this.invitedCount,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'],
      referralCode: json['referral_code'],
      invitedCount: json['invited_count'],
    );
  }
}

