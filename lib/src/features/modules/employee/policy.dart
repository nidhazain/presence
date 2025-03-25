import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/custom_card.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/features/api/employee/policyapi.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  late Future<PolicyResponse> policyData;

  @override
  void initState() {
    super.initState();
    policyData = PolicyService.fetchPolicyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<PolicyResponse>(
        future: policyData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading policy data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          policyData = PolicyService.fetchPolicyData();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: "Leave Policies",
                    items: data.leavePolicies,
                    itemBuilder: (policy) => CustomCard7(
                      title: policy['leave_type'],
                      subtitle: 'Amount: ${policy['amount']} | Frequency: ${policy['frequency']}',
                    ),
                    emptyMessage: "No leave policies have been defined yet.",
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: "Public Holidays",
                    items: data.publicHolidays,
                    itemBuilder: (holiday) => CustomCard9(
                      title: holiday['name'],
                      subtitle: '${holiday['date']} | Community: ${holiday['community__community_name']}',
                    ),
                    emptyMessage: "No public holidays have been scheduled.",
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: "Shifts",
                    items: data.workingHours,
                    itemBuilder: (shift) => CustomCard8(
                      title: shift['shift_type'],
                      subtitle: '${shift['start_time'].substring(0, 5)} - ${shift['end_time'].substring(0, 5)}',
                    ),
                    emptyMessage: "No shift schedules have been defined yet.",
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 70, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No policy data available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSection<T>({
    required String title,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTitleText8(text: title),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: itemBuilder(item),
              )),
      ],
    );
  }
}

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