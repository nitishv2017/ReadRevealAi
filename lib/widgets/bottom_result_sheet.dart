import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../services/api/gemini_service.dart';

/// A bottom sheet widget that displays analysis results with tabs.
///
/// This widget is designed to be used as a common component across
/// the application for displaying text analysis results.
class BottomResultSheet extends StatefulWidget {
  /// The explanation text to display (for backward compatibility)
  final String explanation;
  
  /// The structured analysis result
  final TextAnalysisResult? analysisResult;
  
  /// The image file related to the analysis
  final File? imageFile;
  
  /// Whether the result is currently being saved
  final bool isSaving;
  
  /// Callback for when the user wants to save the result
  final VoidCallback? onSave;
  
  /// Callback for when the user wants to start a new scan
  final VoidCallback? onNewScan;
  
  /// Callback for when the user dismisses the sheet
  final VoidCallback? onDismiss;
  
  /// Maximum height for the sheet as a fraction of screen height
  final double maxHeightFactor;
  
  /// Constructor
  const BottomResultSheet({
    super.key,
    this.explanation = '',
    this.analysisResult,
    this.imageFile,
    this.isSaving = false,
    this.onSave,
    this.onNewScan,
    this.onDismiss,
    this.maxHeightFactor = 0.9,
  });
  
  @override
  State<BottomResultSheet> createState() => _BottomResultSheetState();
  
  /// Static method to show the bottom result sheet
  static Future<void> show({
    required BuildContext context,
    String explanation = '',
    TextAnalysisResult? analysisResult,
    File? imageFile,
    bool isSaving = false,
    VoidCallback? onSave,
    VoidCallback? onNewScan,
    VoidCallback? onDismiss,
    double maxHeightFactor = 0.9,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => BottomResultSheet(
        explanation: explanation,
        analysisResult: analysisResult,
        imageFile: imageFile,
        isSaving: isSaving,
        onSave: onSave,
        onNewScan: onNewScan,
        onDismiss: onDismiss,
        maxHeightFactor: maxHeightFactor,
      ),
    ).then((_) {
      if (onDismiss != null) {
        onDismiss();
      }
    });
  }
}

class _BottomResultSheetState extends State<BottomResultSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLocalSaving = false;
  static const _tabs = [
    Tab(text: 'Summary'),
    Tab(text: 'Hard Words'),
    Tab(text: 'Tough Phrases'),
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isLocalSaving = widget.isSaving;
  }
  
  @override
  void didUpdateWidget(BottomResultSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local saving state if the widget's saving state changes
    if (oldWidget.isSaving != widget.isSaving) {
      setState(() {
        _isLocalSaving = widget.isSaving;
      });
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: widget.maxHeightFactor,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHandle(context),
              if (widget.imageFile != null) _buildImagePreview(context),
              _buildTabBar(),
              Expanded(
                child: _buildTabContent(scrollController),
              ),
              if (widget.onSave != null || widget.onNewScan != null) 
                _buildActionButtons(context),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
  
  Widget _buildImagePreview(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.2,
      ),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          widget.imageFile!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _tabs,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Theme.of(context).primaryColor,
      ),
    );
  }
  
  Widget _buildTabContent(ScrollController scrollController) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSummaryTab(scrollController),
        _buildHardWordsTab(scrollController),
        _buildToughPhrasesTab(scrollController),
      ],
    );
  }
  
  Widget _buildSummaryTab(ScrollController scrollController) {
    if (widget.analysisResult != null) {
      return SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.analysisResult!.summary,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      );
    } else {
      // Fallback to markdown if no structured result
      return _buildMarkdownContent(scrollController, widget.explanation);
    }
  }
  
  Widget _buildHardWordsTab(ScrollController scrollController) {
    if (widget.analysisResult != null && widget.analysisResult!.hardWords.isNotEmpty) {
      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: widget.analysisResult!.hardWords.length,
        itemBuilder: (context, index) {
          final word = widget.analysisResult!.hardWords[index];
          return _buildWordCard(word, index);
        },
      );
    } else {
      return const Center(
        child: Text('No difficult words found'),
      );
    }
  }
  
  Widget _buildToughPhrasesTab(ScrollController scrollController) {
    if (widget.analysisResult != null && widget.analysisResult!.toughPhrases.isNotEmpty) {
      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: widget.analysisResult!.toughPhrases.length,
        itemBuilder: (context, index) {
          final phrase = widget.analysisResult!.toughPhrases[index];
          return _buildPhraseCard(phrase, index);
        },
      );
    } else {
      return const Center(
        child: Text('No complex phrases found'),
      );
    }
  }
  
  Widget _buildWordCard(WordDefinition word, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word.word,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              word.definition,
              style: const TextStyle(fontSize: 16),
            ),
            if (word.example != null && word.example!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Example: ${word.example}',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPhraseCard(PhraseExplanation phrase, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phrase.phrase,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              phrase.explanation,
              style: const TextStyle(fontSize: 16),
            ),
            if (phrase.context != null && phrase.context!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Context: ${phrase.context}',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildMarkdownContent(ScrollController scrollController, String content) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.all(12),
        child: MarkdownBody(
          data: content,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(fontSize: 16, height: 1.5),
            h1: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            h3: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            code: TextStyle(
              backgroundColor: Colors.grey[200],
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            blockquote: TextStyle(
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
            blockquoteDecoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
              border: Border(
                left: BorderSide(
                  color: Colors.grey[400]!,
                  width: 4,
                ),
              ),
            ),
          ),
          onTapLink: (text, href, title) {
            if (href != null) {
              _launchUrl(href);
            }
          },
        ),
      ),
    );
  }
  
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await url_launcher.launchUrl(uri)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (widget.onNewScan != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onNewScan,
                icon: const Icon(Icons.refresh),
                label: const Text('New Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                ),
              ),
            ),
          if (widget.onNewScan != null && widget.onSave != null) 
            const SizedBox(width: 16),
          if (widget.onSave != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLocalSaving ? null : _handleSave,
                icon: Icon(_isLocalSaving ? Icons.hourglass_empty : Icons.save),
                label: Text(_isLocalSaving ? 'Saving...' : 'Save'),
              ),
            ),
        ],
      ),
    );
  }
  
  void _handleSave() async {
    if (widget.onSave == null) return;
    
    setState(() {
      _isLocalSaving = true;
    });
    
    // Call the save function
    widget.onSave!();
    
    // Show a snackbar to confirm saving
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis saved to history'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Close the bottom sheet after saving
      Navigator.of(context).pop();
    }
  }
} 