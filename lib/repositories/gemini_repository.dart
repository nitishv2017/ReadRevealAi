import 'dart:convert';
import 'dart:io';
import '../services/api/gemini_service.dart';

/// Repository for handling image analysis using the Gemini API.
/// 
/// This repository abstracts the conversion of image files to base64 format
/// and provides a simplified interface for getting word explanations.
class GeminiRepository {
  final GeminiService _geminiService;
  
  GeminiRepository(this._geminiService);

  /// Gets structured analysis data for text in an image.
  ///
  /// Takes an [imageFile] and returns a structured [TextAnalysisResult] containing
  /// summary, hard words, and tough phrases.
  Future<TextAnalysisResult> getStructuredAnalysisForImage(File imageFile) async {
    try {
      // Read image file as bytes and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Use the structured analysis method
      return await _geminiService.analyzeImageStructured(base64Image);
    } catch (e) {
      // Pass through the exception
      rethrow;
    }
  }
  
  /// Ensures the response is properly formatted as Markdown.
  /// 
  /// If the response already contains markdown formatting, it's returned as is.
  /// Otherwise, basic formatting is applied.
  String _formatAsMarkdown(String response) {
    // Check if the response already has markdown headings
    if (response.contains('##') || response.contains('#')) {
      return response;
    }
    
    // If not, apply some basic formatting
    final paragraphs = response.split('\n\n');
    if (paragraphs.length >= 2) {
      // Try to identify different sections and format them
      String formatted = '## Summary\n\n${paragraphs.first}\n\n';
      
      formatted += '## Details\n\n';
      for (int i = 1; i < paragraphs.length; i++) {
        if (paragraphs[i].trim().isNotEmpty) {
          formatted += '${paragraphs[i]}\n\n';
        }
      }
      
      return formatted;
    }
    
    // If there's not enough structure to identify sections, return as is
    return response;
  }
} 