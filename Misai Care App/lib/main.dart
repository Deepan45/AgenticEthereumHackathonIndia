import 'package:flutter/material.dart';
import 'package:misai_care/landing_page.dart';

void main() {
  runApp(MisaiCareApp());
}

class MisaiCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misai Care Insurance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1A4D9E), 
        scaffoldBackgroundColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      home: LandingPage(),
    );
  }
}
