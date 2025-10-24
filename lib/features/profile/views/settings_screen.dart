import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: 100,
                color: Colors.grey,
              ),
              SizedBox(height: AppConstants.defaultPadding),
              Text(
                'Settings Screen',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: AppConstants.smallPadding),
              Text(
                'This is a placeholder for the settings screen',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}