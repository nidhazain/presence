// models/employee.dart
class Employee {
  final int empId;
  final String empNum;
  final String name;
  final String? designation;
  final String? community;
  final int workDays;
  final int absentDays;
  final int approvedLeaves;
  final String totalOvertime;
  final String? imageUrl;

  Employee({
    required this.empId,
    required this.empNum,
    required this.name,
    this.designation,
    this.community,
    required this.workDays,
    required this.absentDays,
    required this.approvedLeaves,
    required this.totalOvertime,
    this.imageUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: json['emp_id'],
      empNum: json['emp_num'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'],
      community: json['community'],
      workDays: json['work_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      approvedLeaves: json['approved_leaves'] ?? 0,
      totalOvertime: json['total_overtime'] ?? '0:00',
      imageUrl: json['image'] != null ? 'http://192.168.251.51:8000${json['image']}' : null,
    );
  }
}

class AttendanceReport {
  final Map<String, dynamic> dateRange;
  final Map<String, dynamic> summary;
  final List<Employee> employees;

  AttendanceReport({
    required this.dateRange,
    required this.summary,
    required this.employees,
  });

  factory AttendanceReport.fromJson(Map<String, dynamic> json) {
    return AttendanceReport(
      dateRange: json['date_range'] ?? {},
      summary: json['summary'] ?? {},
      employees: (json['employees'] as List)
          .map((e) => Employee.fromJson(e))
          .toList(),
    );
  }
}