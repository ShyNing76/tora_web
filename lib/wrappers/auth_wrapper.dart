import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;
  
  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasCheckedAuth = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuthIfNeeded();
  }

  Future<void> _checkAuthIfNeeded() async {
    if (!_hasCheckedAuth) {
      _hasCheckedAuth = true;
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.checkAuthStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}