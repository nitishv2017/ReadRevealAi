import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../repositories/gemini_repository.dart';
import '../../repositories/history_repository.dart';
import '../../services/camera/camera_service.dart';
import '../../services/api/gemini_service.dart';

/// Possible states for the camera screen.
enum CameraViewState {
  /// Initial state, ready to capture an image
  initial,
  
  /// Currently capturing an image
  capturing,
  
  /// Processing the captured image
  processing,
  
  /// Displaying the result of processing
  result,
  
  /// An error has occurred
  error,
}

/// View model for the camera screen.
///
/// Manages state and business logic for capturing images,
/// processing them with Gemini API, and saving results to history.
class CameraViewModel extends ChangeNotifier {
  final CameraService _cameraService;
  final GeminiRepository _geminiRepository;
  final HistoryRepository _historyRepository;
  
  // State
  CameraViewState _state = CameraViewState.initial;
  File? _capturedImage;
  String _explanation = '';
  String _errorMessage = '';
  bool _isSaving = false;
  
  // Structured analysis result
  TextAnalysisResult? _analysisResult;
  
  CameraViewModel({
    required CameraService cameraService,
    required GeminiRepository geminiRepository,
    required HistoryRepository historyRepository,
  }) : _cameraService = cameraService,
       _geminiRepository = geminiRepository,
       _historyRepository = historyRepository;
  
  // Getters
  CameraViewState get state => _state;
  File? get capturedImage => _capturedImage;
  String get explanation => _explanation;
  String get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get hasResult => _state == CameraViewState.result && _analysisResult != null;
  
  // Structured result getters
  TextAnalysisResult? get analysisResult => _analysisResult;
  String get summary => _analysisResult?.summary ?? 'No summary available';
  List<WordDefinition> get hardWords => _analysisResult?.hardWords ?? [];
  List<PhraseExplanation> get toughPhrases => _analysisResult?.toughPhrases ?? [];
  bool get hasStructuredResult => _analysisResult != null;
  
  /// Captures an image using the device camera.
  Future<void> captureImage() async {
    try {
      _state = CameraViewState.capturing;
      notifyListeners();
      
      final imageFile = await _cameraService.captureImage();
      if (imageFile != null) {
        _capturedImage = imageFile;
        _state = CameraViewState.processing;
        notifyListeners();
        
        await processImage();
      } else {
        // User canceled image capture
        _state = CameraViewState.initial;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to capture image: $e');
    }
  }
  
  /// Picks an image from the device gallery.
  Future<void> pickImageFromGallery() async {
    try {
      _state = CameraViewState.capturing;
      notifyListeners();
      
      final imageFile = await _cameraService.pickImageFromGallery();
      if (imageFile != null) {
        _capturedImage = imageFile;
        _state = CameraViewState.processing;
        notifyListeners();
        
        await processImage();
      } else {
        // User canceled image selection
        _state = CameraViewState.initial;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to select image: $e');
    }
  }
  
  /// Processes the captured image using Gemini API.
  Future<void> processImage() async {
    if (_capturedImage == null) return;
    
    try {
      _state = CameraViewState.processing;
      notifyListeners();
      
      // Get structured analysis
      _analysisResult = await _geminiRepository.getStructuredAnalysisForImage(_capturedImage!);
      
      // Also get markdown explanation for backward compatibility with history
      _explanation = _generateMarkdownFromResult(_analysisResult!);
      
      _state = CameraViewState.result;
      notifyListeners();
    } catch (e) {
      _setError('Failed to process image: $e');
    }
  }
  
  /// Generates a markdown string from the structured analysis result
  String _generateMarkdownFromResult(TextAnalysisResult result) {
    String markdown = '## Summary\n\n${result.summary}\n\n';
    
    if (result.hardWords.isNotEmpty) {
      markdown += '## Hard Words\n\n';
      for (final word in result.hardWords) {
        markdown += '**${word.word}**: ${word.definition}\n\n';
        if (word.example != null && word.example!.isNotEmpty) {
          markdown += '*Example: ${word.example}*\n\n';
        }
      }
    }
    
    if (result.toughPhrases.isNotEmpty) {
      markdown += '## Tough Phrases\n\n';
      for (final phrase in result.toughPhrases) {
        markdown += '**${phrase.phrase}**: ${phrase.explanation}\n\n';
        if (phrase.context != null && phrase.context!.isNotEmpty) {
          markdown += '*Context: ${phrase.context}*\n\n';
        }
      }
    }
    
    return markdown;
  }
  
  /// Saves the current result to history.
  Future<void> saveToHistory() async {
    if (_capturedImage == null) return;
    
    try {
      _isSaving = true;
      notifyListeners();
      
      if (_analysisResult != null) {
        // Save with structured data if available
        await _historyRepository.saveHistoryWithAnalysis(_capturedImage!, _analysisResult!);
      } else if (_explanation.isNotEmpty) {
        // Fallback to legacy method if no structured data
        await _historyRepository.saveHistory(_capturedImage!, _explanation);
      } else {
        throw Exception('No analysis result to save');
      }
      
      _isSaving = false;
      reset();
    } catch (e) {
      _isSaving = false;
      _setError('Failed to save to history: $e');
    }
  }
  
  /// Resets the view model to its initial state.
  void reset() {
    _state = CameraViewState.initial;
    _capturedImage = null;
    _explanation = '';
    _errorMessage = '';
    _isSaving = false;
    _analysisResult = null;
    notifyListeners();
  }
  
  /// Sets an error message and updates the state.
  void _setError(String message) {
    _errorMessage = message;
    _state = CameraViewState.error;
    notifyListeners();
  }
  
  /// Retry after an error.
  void retry() {
    _state = CameraViewState.initial;
    _errorMessage = '';
    notifyListeners();
  }
} 