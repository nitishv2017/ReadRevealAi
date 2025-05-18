import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage_service.dart';

/// Model class for structured text analysis response
class TextAnalysisResult {
  final String summary;
  final List<WordDefinition> hardWords;
  final List<PhraseExplanation> toughPhrases;

  TextAnalysisResult({
    required this.summary,
    required this.hardWords,
    required this.toughPhrases,
  });

  factory TextAnalysisResult.fromJson(Map<String, dynamic> json) {
    final List<WordDefinition> words = [];
    if (json['hardWords'] != null) {
      for (var word in json['hardWords']) {
        words.add(WordDefinition.fromJson(word));
      }
    }

    final List<PhraseExplanation> phrases = [];
    if (json['toughPhrases'] != null) {
      for (var phrase in json['toughPhrases']) {
        phrases.add(PhraseExplanation.fromJson(phrase));
      }
    }

    return TextAnalysisResult(
      summary: json['summary'] ?? 'No summary available',
      hardWords: words,
      toughPhrases: phrases,
    );
  }

  factory TextAnalysisResult.empty() {
    return TextAnalysisResult(
      summary: 'No content could be analyzed.',
      hardWords: [],
      toughPhrases: [],
    );
  }
}

/// Model for word definitions
class WordDefinition {
  final String word;
  final String definition;
  final String? example;

  WordDefinition({
    required this.word,
    required this.definition,
    this.example,
  });

  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    return WordDefinition(
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      example: json['example'],
    );
  }
}

/// Model for phrase explanations
class PhraseExplanation {
  final String phrase;
  final String explanation;
  final String? context;

  PhraseExplanation({
    required this.phrase,
    required this.explanation,
    this.context,
  });

  factory PhraseExplanation.fromJson(Map<String, dynamic> json) {
    return PhraseExplanation(
      phrase: json['phrase'] ?? '',
      explanation: json['explanation'] ?? '',
      context: json['context'],
    );
  }
}

/// Service for interacting with the Gemini API to analyze images.
class GeminiService {
  final http.Client _client = http.Client();
  final SecureStorageService _storageService;
  
  /// Base URL for the Gemini 2.0 Flash API endpoint
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  GeminiService(this._storageService);

  /// Analyzes an image using Gemini AI and returns structured data.
  /// 
  /// Takes a [base64Image] string and uses function calling to get structured responses.
  /// Returns a [TextAnalysisResult] object with summary, hard words, and tough phrases.
  Future<TextAnalysisResult> analyzeImageStructured(String base64Image) async {
    final apiKey = await _storageService.getApiKey();
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not found. Please set up your Gemini API key in the settings.');
    }
    
    final url = '$_baseUrl?key=$apiKey';
    
    // Function calling definition for structured response
    final payload = {
      'contents': [
        {
          'parts': [
            {
              'text': '''Analyze this image thoroughly and extract all difficult words, phrases, and provide a comprehensive summary. The image contains text that needs detailed analysis.

Please ensure to:
- Maintain the exact order of words and phrases as they appear in the text
- Identify ALL difficult or technical terms, not just the most obvious ones
- Include any specialized vocabulary, jargon, or domain-specific terms
- Note any cultural references, idioms, or context-dependent expressions
- Provide clear, detailed explanations for each term and phrase
- Consider the broader context and implications of the text'''
            },
            {
              'inlineData': {
                'mimeType': 'image/jpeg',
                'data': base64Image
              }
            }
          ]
        }
      ],
      'tools': [
        {
          'functionDeclarations': [
            {
              'name': 'analyzeText',
              'description': 'Perform a thorough analysis of text in the image, extracting all difficult words and phrases while maintaining their original order',
              'parameters': {
                'type': 'OBJECT',
                'properties': {
                  'summary': {
                    'type': 'STRING',
                    'description': 'A detailed and comprehensive summary of the text content in the image (2-3 paragraphs)'
                  },
                  'hardWords': {
                    'type': 'ARRAY',
                    'description': 'Complete list of difficult words with their definitions, maintaining the exact order of appearance in the text. Include ALL technical terms, jargon, and specialized vocabulary.',
                    'items': {
                      'type': 'OBJECT',
                      'properties': {
                        'word': {
                          'type': 'STRING',
                          'description': 'The difficult word or technical term'
                        },
                        'definition': {
                          'type': 'STRING',
                          'description': 'Clear and comprehensive definition of the word'
                        },
                        'example': {
                          'type': 'STRING',
                          'description': 'Practical example showing how the word is used in context'
                        }
                      },
                      'required': ['word', 'definition']
                    }
                  },
                  'toughPhrases': {
                    'type': 'ARRAY',
                    'description': 'Complete list of complex phrases with explanations, maintaining the exact order of appearance in the text. Include ALL idioms, cultural references, and context-dependent phrases.',
                    'items': {
                      'type': 'OBJECT',
                      'properties': {
                        'phrase': {
                          'type': 'STRING',
                          'description': 'The complex phrase or expression'
                        },
                        'explanation': {
                          'type': 'STRING',
                          'description': 'Detailed explanation of the phrase\'s meaning and usage'
                        },
                        'context': {
                          'type': 'STRING',
                          'description': 'Specific context about where and how the phrase is used'
                        }
                      },
                      'required': ['phrase', 'explanation']
                    }
                  }
                },
                'required': ['summary', 'hardWords', 'toughPhrases']
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'topK': 32,
        'topP': 1,
        'maxOutputTokens': 2048
      }
    };
    
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final functionCall = data['candidates'][0]['content']['parts'][0]['functionCall'];
        
        if (functionCall != null && functionCall['name'] == 'analyzeText') {
          final args = functionCall['args'];
          final arguments = args is Map<String, dynamic> ? args : jsonDecode(args as String);
          return TextAnalysisResult.fromJson(arguments);
        } else {
          // Fallback if function calling didn't work as expected
          final textResponse = data['candidates'][0]['content']['parts'][0]['text'] ?? '';
          return TextAnalysisResult(
            summary: textResponse,
            hardWords: [],
            toughPhrases: [],
          );
        }
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with Gemini API: $e');
    }
  }
  
  /// Closes the HTTP client to free up resources.
  void dispose() {
    _client.close();
  }
}