import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Service for handling camera interactions and image picking.
class CameraService {
  final ImagePicker _picker = ImagePicker();
  
  /// Captures an image using the device camera.
  /// 
  /// Returns a [File] object representing the captured image or null if
  /// the user cancels the operation.
  Future<File?> captureImage() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // Slightly compressed for better performance
    );
    
    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }
  
  /// Picks an image from the device gallery.
  /// 
  /// Returns a [File] object representing the selected image or null if
  /// the user cancels the operation.
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Slightly compressed for better performance
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
} 