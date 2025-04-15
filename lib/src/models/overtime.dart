class OvertimeEntry {
  final DateTime date;
  final int hours;
  final String? reason;  
  final String? status;  

  OvertimeEntry({
    required this.date, 
    required this.hours, 
    this.status, 
    this.reason,  
  });

  factory OvertimeEntry.fromJson(Map<String, dynamic> json) {
    return OvertimeEntry(
      date: DateTime.parse(json['date']),
      hours: json['hours'] ?? 0, 
      reason: json['reason'] as String?,  
      status: json['status'] as String?,  
    );
  }
}