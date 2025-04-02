import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/modules/hr/hrattendancestats.dart';

class AttendanceCard extends StatelessWidget {
  final Employee employee;
  final int index;
  final VoidCallback onTap;

  const AttendanceCard({
    Key? key,
    required this.employee,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format overtime from "HH:MM:SS" to "X hrs" or "-" if zero
    final overtime = _formatOvertime(employee.totalOvertime);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primary.withOpacity(.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Display image if available, otherwise use initial avatar
                  employee.imageUrl != null
                      ? CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(employee.imageUrl!),
                        )
                      : CircleAvatar(
                          backgroundColor: _getAvatarColor(index),
                          child: Text(
                            employee.name.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTitleText10(text: employee.name),
                        Text(
                          'ID: ${employee.empNum}', // Use actual employee number from API
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        if (employee.designation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            employee.designation!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoColumn(
                    'Work Days', 
                    '${employee.workDays}', 
                    Colors.blue
                  ),
                  _buildInfoColumn(
                    'Leaves', 
                    employee.approvedLeaves == 0 ? '-' : '${employee.approvedLeaves}', 
                    Colors.orange
                  ),
                  _buildInfoColumn(
                    'Overtime', 
                    overtime, 
                    Colors.green
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatOvertime(String overtime) {
    if (overtime == '0:00' || overtime.isEmpty) return '-';
    
    try {
      final parts = overtime.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        if (hours > 0) return '$hours hr${hours > 1 ? 's' : ''}';
      }
      return '-';
    } catch (e) {
      return '-';
    }
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}