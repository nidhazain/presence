import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  File? _imageFile; 

Future<void> _pickImage() async {
  final pickedFile = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 85, // Compress and ensure JPEG format
  );
  if (pickedFile != null) {
    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage, // Open image picker on tap
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: primary.withOpacity(0.5),
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null, // Show camera icon if no image
                ),
              ),
              const SizedBox(height: 10),
              CustomTitleText8(text: 'Jack Frost'),
              CustomTitleText9(text: 'jack@gmail.com'),
            ],
          ),
        ),
      ),
    );
  }
}
