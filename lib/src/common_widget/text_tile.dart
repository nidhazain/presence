import 'package:flutter/material.dart';
import 'package:presence/src/constants/colors.dart';

class CustomTitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

   const CustomTitleText({
    super.key,
    required this.text,
    this.fontSize = 26,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:  TextStyle(
          fontSize: fontSize,
          color: color,
        
      ),
    );
  }
}

class CustomTitleText2 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

   const CustomTitleText2({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          color: color,
        
      ),
    );
  }
}

class CustomTitleText3 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight; 

  const CustomTitleText3({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.color = primary,
    this.fontWeight = FontWeight.bold, 
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:  TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
        
      ),
    );
  }
}

class CustomTitleText4 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

   const CustomTitleText4({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.color = primary,
    
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          color: color,
        
      ),
    );
  }
}

class CustomTitleText5 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

   const CustomTitleText5({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.color = primary,
    
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:TextStyle(
          fontSize: fontSize,
          color: color,
        
      ),
    );
  }
}

class CustomTitleText6 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

   const CustomTitleText6({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = Colors.white,
    
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          color: color,
        
      ),
    );
  }
}

class CustomTitleText7 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

   const CustomTitleText7({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = primary,
    
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          color: color,
        
      ),
    );
  }
}

class CustomTitleText8 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight; 

  const CustomTitleText8({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.color = primary,
    this.fontWeight = FontWeight.bold, 
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
        
      ),
    );
  }
}

class CustomTitleText9 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

   const CustomTitleText9({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = primary,
    
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:TextStyle(
          fontSize: fontSize,
          color: color,
    
      ),
    );
  }
}

class CustomTitleText10 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

   const CustomTitleText10({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = primary,
    this.fontWeight = FontWeight.bold,
    
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
        
      ),
    );
  }
}

class CustomTitleText11 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

   const CustomTitleText11({
    super.key,
    required this.text,
    this.fontSize = 12,
    this.color = green,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
              fontSize: fontSize,
              color: color,
              decoration: TextDecoration.underline,
              decorationColor: green,
              decorationThickness: 2.0,
            ),
          ),
        
      ],
    );
  }
}

class CustomTitleText12 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
 

   const CustomTitleText12({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = Colors.white,
  
    
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          color: color,

        
      ),
    );
  }
}

class CustomTitleText20 extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

   const CustomTitleText20({
    super.key,
    required this.text,
    this.fontSize = 13,
    this.color = primary,
    
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:TextStyle(
          fontSize: fontSize,
          color: color,
    
      ),
    );
  }
}