class DashboardData {
  final String checkIn;
  final String checkOut;
  final bool late;
  final String overtimeToday;
  final String totalOvertime;
  final double attendancePercentage;
  final String date;
  final List<Map<String, dynamic>> attendanceGraphData;

  DashboardData({
    required this.checkIn,
    required this.checkOut,
    required this.late,
    required this.overtimeToday,
    required this.totalOvertime,
    required this.attendancePercentage,
    required this.date,
    required this.attendanceGraphData,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      late: json['late'],
      overtimeToday: json['overtime_today'],
      totalOvertime: json['total_overtime'],
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
      date: json['date'],
      attendanceGraphData:
          List<Map<String, dynamic>>.from(json['attendance_graph_data']),
    );
  }
}