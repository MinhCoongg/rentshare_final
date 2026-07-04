import 'package:flutter/material.dart';

class BottomSheetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(
      size.width / 2,
      -10,           
      size.width,     
      30,             
    );
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}