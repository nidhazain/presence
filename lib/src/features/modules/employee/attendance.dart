import 'package:flutter/material.dart';
import 'package:presence/src/common_pages/attendance_history.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/modules/employee/attendancestats.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  int _selectedIndex = 0;
  final List<String> tabs = ["stats", "history"];

  final List<Widget> content = [const Attendancestats(), AttendanceHistory()];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            height: MediaQuery.of(context).size.height * 0.07,
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
                    height: MediaQuery.of(context).size.height * 0.05,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(tabs.length, (index) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          //padding: EdgeInsets.all(screenWidth * 0.02),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              color: _selectedIndex == index
                                  ? primary
                                  : primary.withOpacity(.4),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
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
