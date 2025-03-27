class Leave {
  final int id;
  final String type;
  final String startDate;
  final String? endDate;
  final String status;
  final String reason;
  final String? imageUrl;

  Leave({
    required this.id,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.reason,
    this.imageUrl,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      type: json['leave_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      status: json['status'] ?? 'Unknown',
      reason: json['reason'] ?? 'No reason provided',
      imageUrl: json['image'] ?? json['imageUrl'],
    );
  }
}