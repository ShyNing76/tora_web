import 'package:flutter/foundation.dart';
import '../core/services/shared_preferences_service.dart';
import 'base_viewmodel.dart';

class OnboardingViewModel extends BaseViewModel {
  final SharedPreferencesService _prefsService = SharedPreferencesService();
  
  static const String _firstTimeKey = 'isFirstTime';
  static const String _onboardingCompletedKey = 'onboardingCompleted';
  
  bool _isFirstTime = true;
  bool _onboardingCompleted = false;
  
  bool get isFirstTime => _isFirstTime;
  bool get onboardingCompleted => _onboardingCompleted;

  /// Check if this is the first time user opens the app
  Future<bool> checkFirstTime() async {
    setBusy();
    try {
      _isFirstTime = await _prefsService.getBool(_firstTimeKey) ?? true;
      _onboardingCompleted = await _prefsService.getBool(_onboardingCompletedKey) ?? false;
      
      if (kDebugMode) {
        print('First time: $_isFirstTime, Onboarding completed: $_onboardingCompleted');
      }
      
      setIdle();
      notifyListeners();
      return _isFirstTime && !_onboardingCompleted;
    } catch (e) {
      setError('Không thể kiểm tra trạng thái ứng dụng: $e');
      return true; // Default to showing onboarding if error
    }
  }

  /// Mark that user has completed onboarding
  Future<void> completeOnboarding() async {
    setBusy();
    try {
      await _prefsService.setBool(_firstTimeKey, false);
      await _prefsService.setBool(_onboardingCompletedKey, true);
      
      _isFirstTime = false;
      _onboardingCompleted = true;
      
      if (kDebugMode) {
        print('Onboarding completed successfully');
      }
      
      setIdle();
      notifyListeners();
    } catch (e) {
      setError('Không thể lưu trạng thái onboarding: $e');
    }
  }

  /// Skip onboarding (for returning users)
  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }

  /// Reset onboarding (for testing purposes)
  Future<void> resetOnboarding() async {
    setBusy();
    try {
      await _prefsService.remove(_firstTimeKey);
      await _prefsService.remove(_onboardingCompletedKey);
      
      _isFirstTime = true;
      _onboardingCompleted = false;
      
      if (kDebugMode) {
        print('Onboarding reset successfully');
      }
      
      setIdle();
      notifyListeners();
    } catch (e) {
      setError('Không thể reset onboarding: $e');
    }
  }

  /// Check if user should see onboarding
  Future<bool> shouldShowOnboarding() async {
    return await checkFirstTime();
  }
}