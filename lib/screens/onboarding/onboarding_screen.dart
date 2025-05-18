import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'onboarding_view_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OnboardingViewModel>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  // This is handled by the view model, but we need to keep the page controller in sync
                },
                children: [
                  _buildWelcomePage(context),
                  _buildApiKeyPage(context),
                  _buildGetStartedPage(context),
                ],
              ),
            ),
            _buildBottomNavigation(context, viewModel),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/full_RRA.png',
            width: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to ReadReveal AI',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'ReadReveal AI is a mobile app that uses Google\'s Gemini API to analyze and explain text in images. It\'s perfect for quickly understanding complex text from books, documents, or signs.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildApiKeyPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.key,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 32),
          const Text(
            'Set Up Your API Key',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'To use ReadReveal AI, you\'ll need a Gemini API key from Google. You can add your API key in the Settings section after setup.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildApiKeySteps(),
        ],
      ),
    );
  }
  
  Widget _buildApiKeySteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStep(1, 'Go to Google AI Studio and create an API key'),
        const SizedBox(height: 8),
        _buildStep(2, 'Navigate to Settings in this app'),
        const SizedBox(height: 8),
        _buildStep(3, 'Enter your API key in the provided field'),
      ],
    );
  }
  
  Widget _buildStep(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGetStartedPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 100,
            color: Colors.green,
          ),
          const SizedBox(height: 32),
          const Text(
            'You\'re All Set!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'You\'re ready to start using ReadReveal AI. Remember to add your API key in Settings to unlock all features.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigation(BuildContext context, OnboardingViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (hidden on first page)
          viewModel.currentPage > 0
              ? TextButton(
                  onPressed: () {
                    viewModel.previousPage();
                    _pageController.animateToPage(
                      viewModel.currentPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Back'),
                )
              : const SizedBox(width: 80),
          
          // Page indicator
          _buildPageIndicator(viewModel.currentPage),
          
          // Next/Done button
          TextButton(
            onPressed: () async {
              if (viewModel.currentPage < 2) {
                viewModel.nextPage();
                _pageController.animateToPage(
                  viewModel.currentPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                // On last page, complete onboarding and navigate to main app
                await viewModel.completeOnboarding();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              }
            },
            child: Text(viewModel.currentPage == 2 ? 'Get Started' : 'Next'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPageIndicator(int currentPage) {
    return Row(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPage == index ? Colors.blue : Colors.grey[300],
          ),
        ),
      ),
    );
  }
} 