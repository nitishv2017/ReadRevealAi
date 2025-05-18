import 'package:flutter/material.dart';
import '../../services/onboarding/onboarding_service.dart';

class OnboardingViewModel with ChangeNotifier {
  final OnboardingService _onboardingService;
  int _currentPage = 0;
  
  OnboardingViewModel(this._onboardingService);
  
  int get currentPage => _currentPage;

  void nextPage() {
    if (_currentPage < 2) {
      _currentPage++;
      notifyListeners();
    }
  }
  
  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }
  
  Future<void> completeOnboarding() async {
    await _onboardingService.completeOnboarding();
  }
} 