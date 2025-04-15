import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presence/auth/auth_bloc.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
//import 'package:presence/src/features/login/forgotpassword.dart';
import 'package:presence/src/features/modules/employee/attendance.dart';
import 'package:presence/src/features/modules/employee/mainscreen.dart';
import 'package:presence/src/features/modules/hr/hrmainscreen.dart';
import 'package:presence/src/validations/validation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _obscurePassword = true;

  @override
  void initState() {
    //_enableLocationService();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  final roleScreens = {
    'employee': MainScreen(),
    'hr': HRMainScreen(),
    'admin': AttendancePage(),
  };

  void _navigateBasedOnRole(BuildContext context) async {
    String? role = await _storage.read(key: 'role');
    final screen = roleScreens[role?.toLowerCase()];
    if (screen != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => screen));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown role, please contact support')),
      );
    }
  }
 void _enableLocationService() async {
  PermissionStatus permission = await Permission.location.request();

  if (permission.isGranted) {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      //print('User location: $latitude, $longitude');

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

        //print('User address: $address');

        // Store address in secure storage
        await _storage.write(key: 'address', value: address);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  } else if (permission.isDenied) {
    print('Location permission denied.');
  } else if (permission.isPermanentlyDenied) {
    openAppSettings();
  }
}

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.12),
        child: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: primary,
          elevation: 0,
          flexibleSpace: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              child: CustomTitleText(text: 'Login'),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/bg.png', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.12,
                    vertical: screenHeight * 0.08),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenHeight * 0.04),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Image.asset('images/logo.png', height: 40),
                            SizedBox(height: screenHeight * 0.015),
                            CustomTitleText6(text: 'Sign In to Presence'),
                            SizedBox(height: screenHeight * 0.015),
                            TextFormField(
                              controller: _email,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(fontFamily: 'Poppins'),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              validator: ValidationHelper.validateField,
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(fontFamily: 'Poppins'),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: ValidationHelper.validateField,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: GestureDetector(
                            //     onTap: () {
                            //       Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //               builder: (_) =>
                            //                   ForgetPasswordScreen()));
                            //     },
                            //     child:
                            //         CustomTitleText11(text: 'Forgot password?'),
                            //   ),
                            // ),
                            SizedBox(height: screenHeight * 0.01),

                            BlocConsumer<AuthBloc, AuthState>(
                              listener: (context, state) {
                                if (state is Authenticated) {
                                  _enableLocationService(); // Enable location after login
                                  _navigateBasedOnRole(context);
                                } else if (state is AuthFailure) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.error)),
                                  );
                                }
                              },
                              builder: (context, state) {
                                return Container(
                                  padding: EdgeInsets.all(screenHeight * 0.012),
                                  child: ElevatedButton(
                                    onPressed: state is AuthLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              context.read<AuthBloc>().add(
                                                    LoginRequested(
                                                      email: _email.text.trim(),
                                                      password:
                                                          _password.text.trim(),
                                                    ),
                                                  );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                    ),
                                    child: state is AuthLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : Text(
                                            'Submit',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
