import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Adjusted width to make it smaller
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Slightly smaller border radius
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Reduced padding
          minimumSize: Size(100, 40), // Ensures a compact size
        ),
        child: CustomTitleText6(text: text),
      ),
    );
  }
}
