class InsurancePlan {
  final String policyName;
  final String insurer;
  final String sumInsuredRange;
  final String policyTerm;
  final String roomRent;
  final int networkHospitals;

  const InsurancePlan({
    required this.policyName,
    required this.insurer,
    required this.sumInsuredRange,
    this.policyTerm = '1 Year',
    this.roomRent = 'No Limit',
    this.networkHospitals = 10000,
  });

  factory InsurancePlan.fromJson(Map<String, dynamic> json) => InsurancePlan(
        policyName: json['policyName'],
        insurer: json['insurer'],
        sumInsuredRange: json['sumInsuredRange'],
      );
}