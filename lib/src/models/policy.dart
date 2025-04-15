class PolicyResponse {
  final List<dynamic> leavePolicies;
  final List<dynamic> publicHolidays;
  final List<dynamic> workingHours;

  PolicyResponse({
    required this.leavePolicies,
    required this.publicHolidays,
    required this.workingHours,
  });

  factory PolicyResponse.fromJson(Map<String, dynamic> json) {
    return PolicyResponse(
      leavePolicies: json['leave_policies'] ?? [],
      publicHolidays: json['public_holidays'] ?? [],
      workingHours: json['working_hours'] ?? [],
    );
  }
}