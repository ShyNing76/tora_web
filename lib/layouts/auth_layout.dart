import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  
  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Simple scaffold without bottom navigation
    return Scaffold(
      body: child,
    );
  }
}