class VerifiableCredential {
  final String id;
  final List<String> type;
  final String issuer;
  final DateTime issuanceDate;
  final DateTime? expirationDate;
  final Map<String, dynamic> credentialSubject;
  final Map<String, dynamic> proof;

  VerifiableCredential({
    required this.id,
    required this.type,
    required this.issuer,
    required this.issuanceDate,
    this.expirationDate,
    required this.credentialSubject,
    required this.proof,
  });

  factory VerifiableCredential.fromJson(Map<String, dynamic> json) {
    return VerifiableCredential(
      id: json['id'],
      type: List<String>.from(json['type']),
      issuer: json['issuer'],
      issuanceDate: DateTime.parse(json['issuanceDate']),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      credentialSubject: Map<String, dynamic>.from(json['credentialSubject']),
      proof: Map<String, dynamic>.from(json['proof']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'issuer': issuer,
      'issuanceDate': issuanceDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'credentialSubject': credentialSubject,
      'proof': proof,
    };
  }

  bool get isExpired => expirationDate?.isBefore(DateTime.now()) ?? false;

  String get primaryType => type.length > 1 ? type[1] : type[0];

  String get subjectId => credentialSubject['id'];
}