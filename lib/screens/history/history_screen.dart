import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'history_view_model.dart';
import '../../models/history_entry.dart';
import '../../widgets/bottom_result_sheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with WidgetsBindingObserver {
  bool _isInitialized = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);
    
    // Set up focus node to detect when screen gets focus
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    // Delay the loading until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshHistory();
        // Request focus when the widget is first shown
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    // Unregister from lifecycle events
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onFocusChange() {
    if (_focusNode.hasFocus && _isInitialized) {
      _refreshHistory();
    }
  }

  void _refreshHistory() {
    final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
    viewModel.loadHistory();
    _isInitialized = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInitialized) {
      // Refresh history when app is resumed
      _refreshHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HistoryViewModel>(context);
    
    // Handle showing detail sheet outside of the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.hasSelectedEntry && mounted) {
        _showEntryDetailSheet(context, viewModel);
      }
    });
    
    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        body: _buildBody(context, viewModel),
        floatingActionButton: viewModel.hasEntries ? FloatingActionButton(
          onPressed: () => _refreshHistory(),
          child: const Icon(Icons.refresh),
        ) : null,
      ),
    );
  }
  
  Widget _buildBody(BuildContext context, HistoryViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (viewModel.errorMessage != null) {
      return _buildErrorState(context, viewModel);
    }
    
    if (!viewModel.hasEntries) {
      return _buildEmptyState();
    }
    
    return _buildHistoryList(context, viewModel);
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 80,
            color: Colors.black38,
          ),
          const SizedBox(height: 16),
          const Text(
            'No history yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Saved results will appear here',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryList(BuildContext context, HistoryViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Clear All'),
              onPressed: () => _showClearHistoryDialog(context, viewModel),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.entries.length,
            itemBuilder: (context, index) {
              final entry = viewModel.entries[index];
              return _buildHistoryItem(context, entry, viewModel);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildHistoryItem(
    BuildContext context, 
    HistoryEntry entry, 
    HistoryViewModel viewModel
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Image.file(
              File(entry.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),
        ),
        title: Text(
          entry.explanation.split('\n').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Date: ${_formatDate(entry.timestamp)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteDialog(context, entry, viewModel),
        ),
        onTap: () => viewModel.selectEntry(entry),
      ),
    );
  }
  
  void _showEntryDetailSheet(BuildContext context, HistoryViewModel viewModel) {
    if (viewModel.selectedEntry != null && context.mounted) {
      final entry = viewModel.selectedEntry!;
      
      // Clear selection before showing to avoid repeated showing
      viewModel.clearSelection();
      
      // Check if we have structured data in the entry
      final analysisResult = entry.toAnalysisResult();
      
      BottomResultSheet.show(
        context: context,
        explanation: entry.explanation,
        analysisResult: analysisResult,
        imageFile: File(entry.imagePath),
        onNewScan: () {},  // No-op since we're already managing selection state
        onDismiss: () {},  // No-op for the same reason
        maxHeightFactor: 0.9,
      );
    }
  }
  
  Widget _buildErrorState(BuildContext context, HistoryViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.loadHistory,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteDialog(
    BuildContext context, 
    HistoryEntry entry, 
    HistoryViewModel viewModel
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.deleteEntry(entry.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showClearHistoryDialog(BuildContext context, HistoryViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to delete all history entries? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.clearAllHistory();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 