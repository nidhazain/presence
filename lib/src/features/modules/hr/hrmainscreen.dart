import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:presence/src/common_pages/notifications.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/common/loginapi.dart';
import 'package:presence/src/features/api/employee/profileapi.dart';
import 'package:presence/src/features/login/login.dart';
import 'package:presence/src/features/modules/employee/balance.dart';
import 'package:presence/src/features/modules/employee/profile.dart';
import 'package:presence/src/features/modules/employee/policy.dart';
import 'package:presence/src/features/modules/hr/hrattendance.dart';
// import 'package:presence/src/features/modules/hr/hrgraph.dart';
import 'package:presence/src/features/modules/hr/hrhome.dart';
import 'package:presence/src/features/modules/hr/hrleavepage.dart';
import 'package:presence/src/features/modules/hr/hrovertime.dart';
import 'package:presence/src/features/modules/hr/hrselfportal.dart';
import 'package:presence/src/features/modules/hr/hrshift.dart';

class HRMainScreen extends StatefulWidget {
  @override
  HRMainScreenState createState() => HRMainScreenState();
}

class HRMainScreenState extends State<HRMainScreen> {

  int _currentIndex = 0;
    Map<String, dynamic>? _profileData;
  bool _isLoadingProfile = true;

    @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await ProfileService.fetchProfileData();
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
    }
  }


  final List<Widget> _screens = [
    Hrhome(),
    Hrattendance(),
    Hrleavepage(),
    Hrovertime(),
    Hrselfportal(),
    ProfilePage(),
    Hrshift(),
    BalancePage(),
    PolicyPage(),
  ];

  final List<String> _titles = [
    "Welcome",
    "Attendance",
    "Leaves",
    "Overtime",
    "Self Portal",
    "Profile",
    "Shift",
    "Balance",
    "Policy",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
  backgroundColor: primary,
  title: CustomTitleText(text: _titles[_currentIndex]),
  centerTitle: true,
  iconTheme: IconThemeData(color: Colors.white), 
  actions: [
  IconButton(
    icon: Icon(Icons.notifications, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationPage()),
      );
    },
  ),
],

),

        drawer: Drawer(
  backgroundColor: primary,
  child: SafeArea(
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Image.asset(
                'images/logo.png',
                height: 30,
              ),
            ),
            CustomTitleText(text: 'PRESENCE'),
          ],
        ),
        UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: primary),
                accountName: _isLoadingProfile
                    ? CircularProgressIndicator(color: Colors.white)
                    : CustomTitleText2(
                        text: _profileData?['name'] ?? 'User',
                      ),
                accountEmail: Text(
                  _profileData?['position'] ?? 'Designation Not Found',
                  style: TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: _profileData?['image'] != null &&
                          _profileData!['image'].isNotEmpty
                      ? NetworkImage(_profileData!['image'])
                      : AssetImage('images/pro.jpg') as ImageProvider,
                ),
              ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDrawerItem(Icons.home_outlined, "Home", 0),
                _buildDrawerItem(Icons.manage_accounts, "SelfPortal", 4),
                _buildDrawerItem(Icons.person_outline, "Profile", 5),
                _buildDrawerItem(Icons.work_outline, "Shift", 6),
                _buildDrawerItem(Icons.event_available_outlined, "Balance", 7),
                _buildDrawerItem(Icons.policy_outlined, "Policy", 8),
              ],
            ),
          ),
        ),
        Divider(color: Colors.white54),
        _buildDrawerItem(Icons.logout_outlined, "Logout", -1),
      ],
    ),
  ),
),

        body: _screens[_currentIndex],
        bottomNavigationBar: _currentIndex <= 3
            ? CurvedNavigationBar(
                backgroundColor: Colors.white,
                color: primary,
                buttonBackgroundColor: primary,
                height: 60,
                items: [
                  Icon(Icons.home, size: 30, color: Colors.white),
                  Icon(Icons.assignment, size: 30, color: Colors.white),
                  Icon(Icons.event_available, size: 30, color: Colors.white),
                  Icon(Icons.access_time, size: 30, color: Colors.white),
                ],
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              )
            : null, // Hide bottom navigation for non-indexed screens
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 30),
      title: CustomTitleText2(text: title),
      onTap: () async {
        if (index == -1) {
          // Logout logic
          final shouldLogout = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: CustomTitleText3(text: 'Confirm Logout'),
              content: CustomTitleText7(text: "Are you sure you want to log out?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: CustomTitleText8(text: 'Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: CustomTitleText8(text: 'Logout'),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            ApiService apiService = ApiService();
            apiService.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        } else {
          setState(() {
            _currentIndex = index;
            Navigator.pop(context);
          });
        }
      },
    );
  }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchProfile();
  }
} 