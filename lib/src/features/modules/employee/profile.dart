import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presence/src/common_pages/changepassword.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';
import 'package:presence/src/features/api/employee/profileapi.dart';
import 'package:presence/src/features/modules/employee/bloc/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController communityController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController hiringDateController = TextEditingController();

  String profileImageUrl = "";
  bool _controllersSet = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() => _image = File(pickedFile.path));
                    await ProfileService.updateProfileData(
                        imagePath: _image?.path ?? "");
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() => _image = File(pickedFile.path));
                    await ProfileService.updateProfileData(
                        imagePath: _image?.path ?? "");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()
        ..add(FetchProfileData()), // Fetching profile data initially
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is ProfileError) {
                  return Center(child: Text(state.error));
                }

                if (state is ProfileLoaded) {
                  if (!_controllersSet) {
                    fullNameController.text = state.fullName;
                    emailController.text = state.email;
                    positionController.text = state.position;
                    departmentController.text = state.department;
                    communityController.text = state.community;
                    employeeIdController.text = state.employeeId;
                    hiringDateController.text = state.hiringDate;
                    profileImageUrl = state.profileImageUrl;
                    _controllersSet = true;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 70,
                                  backgroundImage: _image != null
                                      ? FileImage(_image!)
                                      : (profileImageUrl.isNotEmpty
                                          ? NetworkImage(profileImageUrl)
                                              as ImageProvider
                                          : const AssetImage('images/pro.jpg')
                                              as ImageProvider),
                                ),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.camera_alt,
                                        color: primary, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 50),
                        ],
                      ),
                      const SizedBox(height: 20),
                      buildProfileField('Employee ID', employeeIdController),
                      buildProfileField('Full Name', fullNameController),
                      buildProfileField('Email', emailController),
                      buildProfileField('Position', positionController),
                      buildProfileField('Department', departmentController),
                      buildProfileField('Hiring Date', hiringDateController),
                      buildProfileField('Community', communityController),
                      const SizedBox(height: 10),
                     
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePasswordPage()),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: primary)
                          ),
                          child: ListTile(
                            title: CustomTitleText9(text: 'Change Password'),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: primary, size: 20),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return SizedBox(); // Return empty widget if state is not matched
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTitleText7(text: label),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: primary.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }
}
