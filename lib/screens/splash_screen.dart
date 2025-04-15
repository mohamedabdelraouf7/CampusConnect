import 'package:flutter/material.dart';
import 'dart:async';
import '../models/app_state.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final AppState appState;
  
  const SplashScreen({Key? key, required this.appState}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(appState: widget.appState),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/campus_connect_logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            // App name
            const Text(
              'CampusConnect',
              style: TextStyle(
                color: Color(0xFF4D8C40),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Tagline
            const Text(
              'Your campus life, organized',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4D8C40)),
            ),
          ],
        ),
      ),
    );
  }
}