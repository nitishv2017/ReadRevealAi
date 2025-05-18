import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'camera_view_model.dart';
import '../../widgets/bottom_result_sheet.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CameraViewModel>(context);
    
    return Scaffold(
      body: _buildBody(context, viewModel),
    );
  }
  
  Widget _buildBody(BuildContext context, CameraViewModel viewModel) {
    switch (viewModel.state) {
      case CameraViewState.initial:
        return _buildInitialState(context, viewModel);
      case CameraViewState.capturing:
        return _buildLoadingState('Capturing image...');
      case CameraViewState.processing:
        return _buildProcessingState(context, viewModel);
      case CameraViewState.result:
        // Use a builder to show the bottom sheet after the first frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showResultBottomSheet(context, viewModel);
        });
        return _buildImagePreview(context, viewModel);
      case CameraViewState.error:
        return _buildErrorState(context, viewModel);
    }
  }

  Widget _buildInitialState(BuildContext context, CameraViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(
            Icons.camera_alt,
            size: 80,
            color: Colors.black54,
          ),
          const SizedBox(height: 20),
          const Text(
            "Snap a pic of tricky text\nand we'll make it easy-peasy to understand!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: viewModel.pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: viewModel.captureImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context, CameraViewModel viewModel) {
    return Column(
      children: [
        Expanded(
          child: viewModel.capturedImage != null
              ? Image.file(
                  viewModel.capturedImage!,
                  fit: BoxFit.contain,
                )
              : const SizedBox(),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: _buildLoadingState('Processing image...'),
        ),
      ],
    );
  }
  
  Widget _buildImagePreview(BuildContext context, CameraViewModel viewModel) {
    if (viewModel.capturedImage == null) {
      return const Center(child: Text('No image available'));
    }
    
    return Center(
      child: Image.file(
        viewModel.capturedImage!,
        fit: BoxFit.contain,
      ),
    );
  }
  
  void _showResultBottomSheet(BuildContext context, CameraViewModel viewModel) {
    // Only show the sheet if we have a result and the context is still valid
    if (viewModel.hasResult && context.mounted) {
      BottomResultSheet.show(
        context: context,
        explanation: viewModel.explanation,
        analysisResult: viewModel.analysisResult,
        imageFile: viewModel.capturedImage,
        isSaving: viewModel.isSaving,
        onSave: viewModel.saveToHistory,
        onNewScan: viewModel.reset,
        onDismiss: viewModel.reset,
      );
    }
  }

  Widget _buildErrorState(BuildContext context, CameraViewModel viewModel) {
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
              viewModel.errorMessage,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.retry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
} 