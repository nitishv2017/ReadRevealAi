import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/camera/camera_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/camera/camera_view_model.dart';
import '../screens/history/history_view_model.dart';
import '../screens/settings/settings_view_model.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/onboarding_view_model.dart';
import '../repositories/gemini_repository.dart';
import '../repositories/history_repository.dart';
import '../services/camera/camera_service.dart';
import '../services/onboarding/onboarding_service.dart';
import 'theme.dart';

class ReadRevealApp extends StatelessWidget {
  const ReadRevealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadReveal AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const OnboardingCheck(),
      routes: {
        '/home': (context) => const AppScaffold(),
      },
    );
  }
}

class OnboardingCheck extends StatefulWidget {
  const OnboardingCheck({super.key});

  @override
  State<OnboardingCheck> createState() => _OnboardingCheckState();
}

class _OnboardingCheckState extends State<OnboardingCheck> {
  bool _isLoading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final onboardingService = Provider.of<OnboardingService>(context, listen: false);
    final hasCompletedOnboarding = await onboardingService.hasCompletedOnboarding();
    
    setState(() {
      _showOnboarding = !hasCompletedOnboarding;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showOnboarding) {
      return ChangeNotifierProvider(
        create: (context) => OnboardingViewModel(
          context.read<OnboardingService>(),
        ),
        child: const OnboardingScreen(),
      );
    }

    return const AppScaffold();
  }
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;
  HistoryViewModel? _historyViewModel;
  bool _historyInitialized = false;

  // Get the current screen based on selected tab
  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return ChangeNotifierProvider(
          create: (context) => CameraViewModel(
            cameraService: context.read<CameraService>(),
            geminiRepository: context.read<GeminiRepository>(),
            historyRepository: context.read<HistoryRepository>(),
          ),
          child: const CameraScreen(),
        );
      case 1:
        return ChangeNotifierProvider(
          create: (context) {
            final viewModel = HistoryViewModel(
              context.read<HistoryRepository>(),
            );
            _historyViewModel = viewModel;
            return viewModel;
          },
          child: const HistoryScreen(),
        );
      case 2:
        return ChangeNotifierProvider(
          create: (context) => SettingsViewModel(
            context.read(),
          ),
          child: const SettingsScreen(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Camera';
      case 1:
        return 'History';
      case 2:
        return 'Settings';
      default:
        return 'ReadReveal AI';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar with no title text
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
} 