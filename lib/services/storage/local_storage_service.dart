import 'package:hive_flutter/hive_flutter.dart';
import '../../models/history_entry.dart';

/// Service for managing local storage of history entries using Hive database.
class LocalStorageService {
  static const String _historyBoxName = 'history_box';
  late Box<HistoryEntry> _historyBox;
  
  /// Initializes Hive database and opens the history box.
  /// 
  /// Must be called before using any other methods in this service.
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HistoryEntryAdapter());
    _historyBox = await Hive.openBox<HistoryEntry>(_historyBoxName);
  }
  
  /// Saves a history entry to the database.
  /// 
  /// Uses the entry's ID as the key for easy retrieval.
  Future<void> saveHistoryEntry(HistoryEntry entry) async {
    await _historyBox.put(entry.id, entry);
  }
  
  /// Retrieves all history entries from the database.
  List<HistoryEntry> getAllHistoryEntries() {
    return _historyBox.values.toList();
  }
  
  /// Retrieves a single history entry by its ID.
  HistoryEntry? getHistoryEntry(String id) {
    return _historyBox.get(id);
  }
  
  /// Deletes a history entry from the database by its ID.
  Future<void> deleteHistoryEntry(String id) async {
    await _historyBox.delete(id);
  }
  
  /// Clears all history entries from the database.
  Future<void> clearAllHistory() async {
    await _historyBox.clear();
  }
  
  /// Closes the Hive box when no longer needed.
  Future<void> close() async {
    await _historyBox.close();
  }
} 