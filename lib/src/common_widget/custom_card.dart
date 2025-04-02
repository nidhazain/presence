import 'package:flutter/material.dart';
import 'package:presence/src/common_widget/text_tile.dart';
import 'package:presence/src/constants/colors.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? fillColor;
  
  const CustomCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.fillColor, 
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: fillColor ?? Colors.white,width: 3),
        borderRadius: BorderRadius.circular(20),
        color: fillColor ?? Colors.white, 
        // boxShadow: [
        //   BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        // ],
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     blurRadius: 3,
        //     spreadRadius: 1,
        //     offset: Offset(4, 4),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon, size: 30, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTitleText10(text: subtitle),
                const SizedBox(height: 5),
                CustomTitleText7(text: title),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCard1 extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? fillColor;

  const CustomCard1({
    super.key,
    required this.title,
    required this.subtitle,
    this.fillColor, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: fillColor ?? Colors.white,width: 2),
        borderRadius: BorderRadius.circular(20),
        color: fillColor ?? Colors.white, 
        // boxShadow: [
        //   BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTitleText8(
                  text: subtitle,
                ),
                const SizedBox(height: 10),
                CustomTitleText20(
                  text: title,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCard2 extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomCard2({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: blue,width: 2),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     blurRadius: 5,
        //     spreadRadius: 1,
        //     offset: Offset(4, 4),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTitleText8(text: title),
          const SizedBox(height: 10),
          CustomTitleText7(text: subtitle)
        ],
      ),
    );
  }

}

class CustomCard3 extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomCard3({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: primary.withOpacity(.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTitleText7(text: title),
          const SizedBox(height: 10),
          CustomTitleText4(text: subtitle)
        ],
      ),
    );
  }
}

class CustomCard4 extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomCard4({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        //border: Border.all(color: blue),
        borderRadius: BorderRadius.circular(10),
        color: primary.withOpacity(.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTitleText10(text: title),
          CustomTitleText9(text: subtitle)
        ],
      ),
    );
  }

}



class CustomCard5 extends StatelessWidget {
  final Icon icons;
  final String title;
  final String subtitle;

  const CustomCard5({super.key, required this.title, required this.subtitle, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: blue, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: blue.withOpacity(.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icons, // ✅ Directly use the `Icon` widget
          SizedBox(width: 40), // ✅ Adds spacing between icon and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // ✅ Aligns text to the start
            mainAxisAlignment: MainAxisAlignment.center, // ✅ Centers text vertically
            children: [
              CustomTitleText9(text: title),
              SizedBox(height: 5),
              CustomTitleText8(text: subtitle),
            ],
          ),
        ],
      ),
    );
  }
}

class textfield extends StatelessWidget {
  final String data;
  const textfield({
    super.key, required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: primary.withOpacity(.1)),
        child: CustomTitleText9(text: data));
  }
}

class CustomCard6 extends StatelessWidget {
  final String title;
  final String title1;
  final String subtitle;

  const CustomCard6({
    super.key,
    required this.title,
    required this.subtitle,
    required this.title1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: primary.withOpacity(0.1),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTitleText10(text: title1),
                CustomTitleText9(text: title),
              ],
            ),
          ),
          CustomTitleText9(text: subtitle),
        ],
      ),
    );
  }
}

class CustomCard7 extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomCard7({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        //border: Border.all(color: blue),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: red),
        color: red.withOpacity(.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTitleText10(text: title),
          CustomTitleText9(text: subtitle)
        ],
      ),
    );
  }

}

class CustomCard8 extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomCard8({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        //border: Border.all(color: blue),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: blue),
        color: blue.withOpacity(.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTitleText10(text: title),
          CustomTitleText9(text: subtitle)
        ],
      ),
    );
  }

}

class CustomCard9 extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomCard9({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        //border: Border.all(color: blue),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: pink),
        color: pink.withOpacity(.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTitleText10(text: title),
          CustomTitleText9(text: subtitle)
        ],
      ),
    );
  }

}

class CustomCard10 extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomCard10({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: blue,width: 2),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     blurRadius: 5,
        //     spreadRadius: 1,
        //     offset: Offset(4, 4),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTitleText8(text: title),
          const SizedBox(height: 10),
          CustomTitleText7(text: subtitle)
        ],
      ),
    );
  }

}
