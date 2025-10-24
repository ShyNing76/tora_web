import 'package:flutter/material.dart';

enum ViewState { idle, busy, error }

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String _errorMessage = '';

  ViewState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isBusy => _state == ViewState.busy;
  bool get hasError => _state == ViewState.error;
  bool get isIdle => _state == ViewState.idle;

  void setState(ViewState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void setError(String error) {
    _errorMessage = error;
    _state = ViewState.error;
    notifyListeners();
  }

  void setBusy() {
    setState(ViewState.busy);
  }

  void setIdle() {
    setState(ViewState.idle);
  }

  void clearError() {
    _errorMessage = '';
    if (_state == ViewState.error) {
      setState(ViewState.idle);
    }
  }

  // Helper method to handle async operations with error handling
  Future<T?> runBusyFuture<T>(Future<T> future) async {
    try {
      setBusy();
      final result = await future;
      setIdle();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}