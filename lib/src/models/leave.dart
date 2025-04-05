class Leave {
  final int id;
  final String type;
  final String startDate;
  final String? endDate;
  final String status;
  final String reason;
  final String? imageUrl;
  final String? cancellationReason;

  Leave({
    required this.id,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.reason,
    this.imageUrl,
    this.cancellationReason,
  });

factory Leave.fromJson(Map<String, dynamic> json) {
 //print('Raw JSON from API: $json');  // Add this to see the raw data
  return Leave(
    id: json['id'],
    type: json['leave_type'] ?? '',
    startDate: json['start_date'] ?? '',
    endDate: json['end_date'],
    status: json['status'] ?? 'Unknown',
    reason: json['reason'] ?? 'No reason provided',
    imageUrl: json['image'],
    cancellationReason: json['cancellation_reason'] ?? json['cancellationReason'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_type': type,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'reason': reason,
      'image': imageUrl,
      'cancellation_reason': cancellationReason,
    };
  }
}