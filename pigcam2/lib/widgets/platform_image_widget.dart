import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformImageWidget extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final String? imagePath; // Add support for image paths
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const PlatformImageWidget({
    Key? key,
    this.imageFile,
    this.imageBytes,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web platform - use Image.memory with bytes
      if (imageBytes != null) {
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.memory(
            imageBytes!,
            width: width,
            height: height,
            fit: fit,
          ),
        );
      } else {
        return _buildPlaceholder();
      }
    } else {
      // Mobile platform - use Image.file
      if (imageFile != null) {
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.file(
            imageFile!,
            width: width,
            height: height,
            fit: fit,
          ),
        );
      } else if (imagePath != null) {
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.file(
            File(imagePath!),
            width: width,
            height: height,
            fit: fit,
          ),
        );
      } else {
        return _buildPlaceholder();
      }
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Icon(
        Icons.image,
        color: Colors.grey[600],
        size: 40,
      ),
    );
  }
} 