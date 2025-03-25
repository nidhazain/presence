// import 'package:flutter/material.dart';
// import 'package:presence/src/common_widget/text_tile.dart';
// import 'package:presence/src/constants/colors.dart';
// import 'package:presence/src/features/api/api.dart';
// import 'package:presence/src/features/login/forgotpassword.dart';
// import 'package:presence/src/features/modules/employee/attendance.dart';
// import 'package:presence/src/features/modules/employee/mainscreen.dart';
// import 'package:presence/src/features/modules/employee/overtime.dart';
// import 'package:presence/src/validations/validation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final ApiService apiService = ApiService();

//   final TextEditingController _email = TextEditingController();
//   final TextEditingController _password = TextEditingController();
//   final _storage = const FlutterSecureStorage();

//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       final response = await ApiService.login(_email.text, _password.text);

//       if (response != null && response['access'] != null) {
//         // Fetch role from secure storage
//         String? role = await _storage.read(key: 'role');
//         if (role == 'employee' || role == 'Employee') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => MainScreen()),
//           );
//         } else if (role == 'hr') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => OvertimePage()),
//           );
//         } else if (role == 'admin') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => AttendancePage()),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Unknown role, please contact support')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(response?['error'] ?? 'Login failed')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(screenHeight * 0.12),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           centerTitle: true,
//           backgroundColor: primary,
//           elevation: 0,
//           flexibleSpace: Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//               child: CustomTitleText(text: 'Login'),
//             ),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'images/bg.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.12,
//                     vertical: screenHeight * 0.08),
//                 child: Column(
//                   children: [
//                     CustomTitleText2(text: 'Welcome!!'),
//                     SizedBox(height: screenHeight * 0.015),
//                     // CustomTitleText6(text: 'enter the credentials'),
//                     // SizedBox(height: screenHeight * 0.015),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.06,
//                           vertical: screenHeight * 0.04),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: Colors.grey.withOpacity(0.2),
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           children: [
//                             Image.asset('images/logo.png', height: 40,),
//                             SizedBox(height: screenHeight * 0.015),
//                             CustomTitleText6(text: 'Sign In to Presence'),
//                             SizedBox(height: screenHeight * 0.015),
//                             TextFormField(
//                               controller: _email,
//                               decoration: InputDecoration(
//                                 hintText: 'Email',
//                                 hintStyle: TextStyle(fontFamily: 'Poppins'),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                               ),
//                               validator: ValidationHelper.validateField,
//                             ),
//                             SizedBox(height: screenHeight * 0.015),
//                             TextFormField(
//                               controller: _password,
//                               obscureText: _obscurePassword,
//                               decoration: InputDecoration(
//                                 hintText: 'Password',
//                                 hintStyle: TextStyle(fontFamily: 'Poppins'),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     _obscurePassword
//                                         ? Icons.visibility_off
//                                         : Icons.visibility,
//                                   ),
//                                   onPressed: () {
//                                     setState(() {
//                                       _obscurePassword = !_obscurePassword;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               validator: ValidationHelper.validateField,
//                             ),
//                             SizedBox(height: screenHeight * 0.01),
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             ForgetPasswordScreen()),
//                                   );
//                                 },
//                                 child: CustomTitleText11(text: 'Forgot password?'),
//                               ),
//                             ),
//                             SizedBox(height: screenHeight * 0.01),
//                             Container(
//                               padding: EdgeInsets.all(screenHeight * 0.012),
//                               child: ElevatedButton(
//                                 onPressed: _handleLogin,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: primary,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(50),
//                                   ),
//                                 ),
//                                 child: _isLoading
//                                     ? const CircularProgressIndicator(
//                                         color: Colors.white)
//                                     : Text(
//                                         'Submit',
//                                         style: const TextStyle(
//                                           fontSize: 20,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
