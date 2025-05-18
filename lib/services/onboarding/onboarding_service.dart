import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';

  /// Checks if the user has completed the onboarding process
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  /// Marks the onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);
  }

  /// Resets the onboarding status (for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, false);
  }
} 