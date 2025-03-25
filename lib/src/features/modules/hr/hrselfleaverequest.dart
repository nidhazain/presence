import 'package:flutter/material.dart';
import 'package:presence/src/common_pages/leave_history.dart';
import 'package:presence/src/common_pages/leaveform.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/api.dart';


class HRLeaveRequestPage extends StatefulWidget {
  const HRLeaveRequestPage({super.key});

  @override
  _HRLeaveRequestPageState createState() => _HRLeaveRequestPageState();
}

class _HRLeaveRequestPageState extends State<HRLeaveRequestPage> {
  int _selectedIndex = 0;
  final List<String> tabs = ["request", "history"];
  final List<Widget> content = [
    LeaveForm(),
    LeaveHistory(),

  ];

  int totalLeave = 0;
  int usedLeave = 0;
  int availableLeave = 0;

  @override
  void initState() {
    super.initState();
    fetchLeaveData();
  }

Future<void> fetchLeaveData() async {
  try {
    final leaveData = await LeaveService.getLeaveBalance();
    if (!mounted) return; 
    setState(() {
      totalLeave = leaveData['total_leave'];
      usedLeave = leaveData['used_leave'];
      availableLeave = leaveData['available_leave'];
    });
  } catch (e) {
    print("Error fetching leave balance: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
  backgroundColor: primary,
  title: CustomTitleText(text: 'Leave Request'),
  centerTitle: true,
  iconTheme: IconThemeData(color: Colors.white), 
),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              padding: EdgeInsets.all(screenWidth * 0.025),
              height: screenHeight * 0.11,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.symmetric(
                vertical: BorderSide.none,
                horizontal:
                    BorderSide(width: 2, color: primary.withOpacity(.3)),
              )),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          CustomTitleText9(text: 'Balance leave'),
                    
                          CustomTitleText5(text: '$availableLeave'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(screenWidth * 0.025),
                    width: 2,
                    height: screenHeight * 0.05,
                    color: primary.withOpacity(0.3),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          CustomTitleText9(text: 'Used leave'),
            
                          CustomTitleText5(text: '$usedLeave'),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 20),
                    Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
            height: screenHeight * 0.06,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: _selectedIndex == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width / tabs.length - 40,
                    height: MediaQuery.of(context).size.height * 0.04,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(tabs.length, (index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          width: screenWidth / tabs.length - 30, 
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.015,
            horizontal: screenWidth * 0.025),
          child: Text(
            tabs[index],
            style: TextStyle(
              color: _selectedIndex == index
                  ? primary
                  : primary.withOpacity(.4),
              fontSize: 16,
            ),
          ),
        ),
      );
    }),
  ),
)

                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Container(
                key: ValueKey<int>(_selectedIndex),
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: content[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
