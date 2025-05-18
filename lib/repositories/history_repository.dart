import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/history_entry.dart';
import '../services/storage/local_storage_service.dart';
import '../services/api/gemini_service.dart';

/// Repository for managing history entries and related image files.
class HistoryRepository {
  final LocalStorageService _storageService;
  final Uuid _uuid = const Uuid();
  
  HistoryRepository(this._storageService);
  
  /// Saves a new history entry with the captured image and its explanation.
  /// 
  /// Copies the image file to the app's documents directory for persistence.
  /// Generates unique IDs for both the file and the history entry.
  Future<void> saveHistory(File imageFile, String explanation) async {
    // Get app documents directory for persistent storage
    final appDir = await getApplicationDocumentsDirectory();
    final filename = '${_uuid.v4()}.jpg';
    final savedImagePath = path.join(appDir.path, filename);
    
    // Copy the image file to app documents directory
    await imageFile.copy(savedImagePath);
    
    // Create a new history entry
    final entry = HistoryEntry(
      id: _uuid.v4(),
      imagePath: savedImagePath,
      explanation: explanation,
      timestamp: DateTime.now(),
    );
    
    // Save to local storage
    await _storageService.saveHistoryEntry(entry);
  }
  
  /// Saves a new history entry with the captured image and structured analysis result.
  /// 
  /// This is the preferred method for saving history entries with the new data model.
  Future<void> saveHistoryWithAnalysis(File imageFile, TextAnalysisResult analysisResult) async {
    // Get app documents directory for persistent storage
    final appDir = await getApplicationDocumentsDirectory();
    final filename = '${_uuid.v4()}.jpg';
    final savedImagePath = path.join(appDir.path, filename);
    
    // Copy the image file to app documents directory
    await imageFile.copy(savedImagePath);
    
    // Create a new history entry from the analysis result
    final entry = HistoryEntry.fromAnalysisResult(
      id: _uuid.v4(),
      imagePath: savedImagePath,
      result: analysisResult,
    );
    
    // Save to local storage
    await _storageService.saveHistoryEntry(entry);
  }
  
  /// Retrieves all history entries, sorted by timestamp (newest first).
  List<HistoryEntry> getAllHistory() {
    final entries = _storageService.getAllHistoryEntries();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }
  
  /// Retrieves a single history entry by its ID.
  HistoryEntry? getHistoryEntry(String id) {
    return _storageService.getHistoryEntry(id);
  }
  
  /// Deletes a history entry and its associated image file.
  Future<void> deleteHistoryEntry(String id) async {
    final entry = _storageService.getHistoryEntry(id);
    
    if (entry != null) {
      // Delete the image file
      final imageFile = File(entry.imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      
      // Delete entry from storage
      await _storageService.deleteHistoryEntry(id);
    }
  }
  
  /// Clears all history entries and their associated image files.
  Future<void> clearAllHistory() async {
    final entries = getAllHistory();
    
    // Delete all image files
    for (final entry in entries) {
      final imageFile = File(entry.imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }
    
    // Clear all entries from storage
    await _storageService.clearAllHistory();
  }
} 