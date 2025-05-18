import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'repositories/gemini_repository.dart';
import 'repositories/history_repository.dart';
import 'services/api/gemini_service.dart';
import 'services/camera/camera_service.dart';
import 'services/storage/local_storage_service.dart';
import 'services/storage/secure_storage_service.dart';
import 'services/onboarding/onboarding_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  
  final secureStorageService = SecureStorageService();
  final onboardingService = OnboardingService();
  
  // Run app with providers
  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<CameraService>(
          create: (_) => CameraService(),
        ),
        Provider<SecureStorageService>(
          create: (_) => secureStorageService,
        ),
        Provider<LocalStorageService>(
          create: (_) => localStorageService,
        ),
        Provider<GeminiService>(
          create: (context) => GeminiService(
            context.read<SecureStorageService>(),
          ),
        ),
        Provider<OnboardingService>(
          create: (_) => onboardingService,
        ),
        
        // Repositories
        Provider<GeminiRepository>(
          create: (context) => GeminiRepository(
            context.read<GeminiService>(),
          ),
        ),
        Provider<HistoryRepository>(
          create: (context) => HistoryRepository(
            context.read<LocalStorageService>(),
          ),
        ),
      ],
      child: const ReadRevealApp(),
    ),
  );
}
