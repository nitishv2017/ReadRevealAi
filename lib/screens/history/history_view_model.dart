import 'package:flutter/foundation.dart';
import '../../models/history_entry.dart';
import '../../repositories/history_repository.dart';

/// View model for the history screen.
///
/// Manages state and business logic for displaying, selecting, and
/// deleting history entries.
class HistoryViewModel extends ChangeNotifier {
  final HistoryRepository _historyRepository;
  
  List<HistoryEntry> _entries = [];
  HistoryEntry? _selectedEntry;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDeleting = false;
  
  HistoryViewModel(this._historyRepository) {
    loadHistory();
  }
  
  // Getters
  List<HistoryEntry> get entries => _entries;
  HistoryEntry? get selectedEntry => _selectedEntry;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  bool get hasEntries => _entries.isNotEmpty;
  bool get hasSelectedEntry => _selectedEntry != null;
  
  /// Loads all history entries from the repository.
  Future<void> loadHistory() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _entries = _historyRepository.getAllHistory();
      // Entries are already sorted in the repository
    } catch (e) {
      _errorMessage = 'Failed to load history: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Selects a history entry for detailed view.
  void selectEntry(HistoryEntry entry) {
    _selectedEntry = entry;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Clears the selected history entry.
  void clearSelection() {
    _selectedEntry = null;
    notifyListeners();
  }
  
  /// Deletes a history entry by its ID.
  Future<void> deleteEntry(String id) async {
    if (_isDeleting) return; // Prevent multiple simultaneous deletes
    
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _historyRepository.deleteHistoryEntry(id);
      
      // Clear selection if the deleted entry was selected
      if (_selectedEntry?.id == id) {
        _selectedEntry = null;
      }
      
      // Reload the entries list
      await loadHistory();
    } catch (e) {
      _errorMessage = 'Failed to delete entry: $e';
      _isLoading = false;
      _isDeleting = false;
      notifyListeners();
    }
  }
  
  /// Deletes all history entries.
  Future<void> clearAllHistory() async {
    if (_isDeleting) return; // Prevent multiple simultaneous clears
    
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _historyRepository.clearAllHistory();
      _selectedEntry = null;
      await loadHistory();
    } catch (e) {
      _errorMessage = 'Failed to clear history: $e';
      _isDeleting = false;
      notifyListeners();
    }
  }
  
  /// Clears any error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 