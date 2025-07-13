class Recommendation {
  final String policyId;
  final String policyName;
  final int score;
  final List<String> matchReasons;
  final String why;
  final String summary;
  final DateTime generatedAt;

  // ✅ Add these optional fields
  final String? abhaId;
  final String? did;
  final String? walletAddress;

  const Recommendation({
    required this.policyId,
    required this.policyName,
    required this.score,
    required this.matchReasons,
    required this.why,
    required this.summary,
    required this.generatedAt,
    this.abhaId,
    this.did,
    this.walletAddress,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      policyId: json['policyId'] ?? '',
      policyName: json['policyName'] ?? '',
      score: json['score'] ?? 0,
      matchReasons: List<String>.from(json['matchReasons'] ?? []),
      why: json['why'] ?? '',
      summary: json['summary'] ?? '',
      generatedAt: DateTime.tryParse(json['generatedAt'] ?? '') ?? DateTime.now(),
      abhaId: json['abhaId'],             // optional
      did: json['did'],                   // optional
      walletAddress: json['walletAddress'], // optional
    );
  }

  String get scoreDisplay => '$score% Match';
}
