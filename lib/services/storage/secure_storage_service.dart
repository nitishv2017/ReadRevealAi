import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data like API keys.
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _apiKeyKey = 'gemini_api_key';
  
  /// Saves the Gemini API key securely.
  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }
  
  /// Retrieves the stored Gemini API key.
  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }
  
  /// Checks if an API key is stored and not empty.
  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
  
  /// Deletes the stored API key.
  Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }
} 