import 'package:hive/hive.dart';
import '../services/api/gemini_service.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 0)
class HistoryEntry {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String imagePath;
  
  @HiveField(2)
  final String explanation;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final String? summary;
  
  @HiveField(5)
  final List<Map<String, dynamic>>? hardWords;
  
  @HiveField(6)
  final List<Map<String, dynamic>>? toughPhrases;
  
  const HistoryEntry({
    required this.id,
    required this.imagePath,
    required this.explanation,
    required this.timestamp,
    this.summary,
    this.hardWords,
    this.toughPhrases,
  });
  
  // Factory method to create from TextAnalysisResult
  factory HistoryEntry.fromAnalysisResult({
    required String id,
    required String imagePath,
    required TextAnalysisResult result,
  }) {
    // Convert WordDefinition objects to maps
    final List<Map<String, dynamic>> wordMaps = result.hardWords.map((word) => {
      'word': word.word,
      'definition': word.definition,
      'example': word.example,
    }).toList();
    
    // Convert PhraseExplanation objects to maps
    final List<Map<String, dynamic>> phraseMaps = result.toughPhrases.map((phrase) => {
      'phrase': phrase.phrase,
      'explanation': phrase.explanation,
      'context': phrase.context,
    }).toList();
    
    // Generate markdown explanation for backward compatibility
    String explanation = '## Summary\n\n${result.summary}\n\n';
    
    if (result.hardWords.isNotEmpty) {
      explanation += '## Hard Words\n\n';
      for (final word in result.hardWords) {
        explanation += '**${word.word}**: ${word.definition}\n\n';
        if (word.example != null && word.example!.isNotEmpty) {
          explanation += '*Example: ${word.example}*\n\n';
        }
      }
    }
    
    if (result.toughPhrases.isNotEmpty) {
      explanation += '## Tough Phrases\n\n';
      for (final phrase in result.toughPhrases) {
        explanation += '**${phrase.phrase}**: ${phrase.explanation}\n\n';
        if (phrase.context != null && phrase.context!.isNotEmpty) {
          explanation += '*Context: ${phrase.context}*\n\n';
        }
      }
    }
    
    return HistoryEntry(
      id: id,
      imagePath: imagePath,
      explanation: explanation,
      timestamp: DateTime.now(),
      summary: result.summary,
      hardWords: wordMaps,
      toughPhrases: phraseMaps,
    );
  }

  // Create a copy of the object with modified fields
  HistoryEntry copyWith({
    String? id,
    String? imagePath,
    String? explanation,
    DateTime? timestamp,
    String? summary,
    List<Map<String, dynamic>>? hardWords,
    List<Map<String, dynamic>>? toughPhrases,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      explanation: explanation ?? this.explanation,
      timestamp: timestamp ?? this.timestamp,
      summary: summary ?? this.summary,
      hardWords: hardWords ?? this.hardWords,
      toughPhrases: toughPhrases ?? this.toughPhrases,
    );
  }

  // Convert structured data back to TextAnalysisResult
  TextAnalysisResult? toAnalysisResult() {
    if (summary == null || hardWords == null || toughPhrases == null) {
      return null;
    }
    
    try {
      // Convert maps back to WordDefinition objects
      final List<WordDefinition> words = hardWords!.map((dynamic map) {
        final mapData = map is Map<String, dynamic> 
            ? map 
            : Map<String, dynamic>.from(map as Map);
        
        return WordDefinition(
          word: mapData['word'] ?? '',
          definition: mapData['definition'] ?? '',
          example: mapData['example'],
        );
      }).toList();
      
      // Convert maps back to PhraseExplanation objects
      final List<PhraseExplanation> phrases = toughPhrases!.map((dynamic map) {
        final mapData = map is Map<String, dynamic> 
            ? map 
            : Map<String, dynamic>.from(map as Map);
            
        return PhraseExplanation(
          phrase: mapData['phrase'] ?? '',
          explanation: mapData['explanation'] ?? '',
          context: mapData['context'],
        );
      }).toList();
      
      return TextAnalysisResult(
        summary: summary!,
        hardWords: words,
        toughPhrases: phrases,
      );
    } catch (e) {
      print('Error converting to TextAnalysisResult: $e');
      return null;
    }
  }

  // String representation for debugging
  @override
  String toString() {
    return 'HistoryEntry(id: $id, imagePath: $imagePath, timestamp: $timestamp)';
  }
} 