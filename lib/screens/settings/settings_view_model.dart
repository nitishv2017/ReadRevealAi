import 'package:flutter/foundation.dart';
import '../../services/storage/secure_storage_service.dart';

/// View model for the settings screen.
///
/// Manages state and business logic for API key storage and retrieval.
class SettingsViewModel extends ChangeNotifier {
  final SecureStorageService _storageService;
  
  bool _isLoading = false;
  bool _hasApiKey = false;
  String _apiKey = '';
  String? _errorMessage;
  
  SettingsViewModel(this._storageService) {
    _checkForApiKey();
  }
  
  // Getters
  bool get isLoading => _isLoading;
  bool get hasApiKey => _hasApiKey;
  String get apiKey => _apiKey;
  String? get errorMessage => _errorMessage;
  
  /// Checks if an API key is already stored.
  Future<void> _checkForApiKey() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _hasApiKey = await _storageService.hasApiKey();
    } catch (e) {
      _errorMessage = 'Failed to check API key: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Updates the API key value (does not save it).
  void updateApiKey(String value) {
    _apiKey = value;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Saves the API key to secure storage.
  Future<bool> saveApiKey() async {
    if (_apiKey.isEmpty) {
      _errorMessage = 'API key cannot be empty';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _storageService.saveApiKey(_apiKey);
      _hasApiKey = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save API key: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Clears the stored API key.
  Future<void> clearApiKey() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _storageService.deleteApiKey();
      _hasApiKey = false;
      _apiKey = '';
    } catch (e) {
      _errorMessage = 'Failed to clear API key: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Clears any error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 