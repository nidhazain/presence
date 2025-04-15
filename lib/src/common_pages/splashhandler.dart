import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presence/src/common_pages/splash.dart';
import 'package:presence/src/features/login/login.dart';
import 'package:presence/src/features/modules/employee/mainscreen.dart';
import 'package:presence/src/features/modules/hr/hrmainscreen.dart';


class SplashScreenHandler extends StatefulWidget {
  const SplashScreenHandler({super.key});

  @override
  State<SplashScreenHandler> createState() => _SplashScreenHandlerState();
}

class _SplashScreenHandlerState extends State<SplashScreenHandler> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3)); 
    final storage = FlutterSecureStorage();
    String? role = await storage.read(key: 'role');
    print("Role detected: $role");

    Widget targetScreen;
    if (role?.toLowerCase() == 'employee') {
      targetScreen = MainScreen();
    } else if (role?.toLowerCase() == 'hr') {
      targetScreen = HRMainScreen();
    } else {
      targetScreen = LoginScreen();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
