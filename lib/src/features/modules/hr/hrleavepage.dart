import 'package:flutter/material.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/modules/hr/hrcancellation.dart';
import 'package:presence/src/features/modules/hr/hrleaverequest.dart';
import 'package:presence/src/features/modules/hr/hrleavehistory.dart';

class Hrleavepage extends StatefulWidget {
  const Hrleavepage({super.key});

  @override
  HrleavepageState createState() => HrleavepageState();
}

class HrleavepageState extends State<Hrleavepage> {
  int _selectedIndex = 0;
  
  final List<String> tabs = ["leave", "cancellation", "history"];


  final List<Widget> content = [
    LeaveRequestPage(), 
    LeaveCancellationRequestList(), 
    HrLeaveHistory() 
  ];

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
                      : _selectedIndex == 1
                          ? Alignment.center
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