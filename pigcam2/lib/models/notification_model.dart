import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:pigcam2/services/image_classification_service.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final Uint8List? imageBytes;
  final List<ClassificationResult>? classificationResults;
  final String? source;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.imageBytes,
    this.classificationResults,
    this.source,
    this.isRead = false,
  });

  get iconData => null;

  // A simple method to create a notification for image capture
  static NotificationModel imageCaptureNotification({
    required Uint8List imageBytes,
    String title = 'New Image Captured',
    String message = 'An image has been captured by the ESP32-CAM.',
  }) {
    return NotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      imageBytes: imageBytes,
    );
  }

  // Method to create a notification for classification results
  static NotificationModel classificationNotification({
    required List<ClassificationResult> results,
    required String source,
    Uint8List? imageBytes,
    String? customTitle,
    String? customMessage,
  }) {
    final hasHighSeverity = results.any((r) => 
      r.severity == 'High' || r.severity == 'Very High');
    
    final requiresAction = results.any((r) => r.requiresAction);
    
    String title = customTitle ?? 'Classification Complete';
    String message = customMessage ?? 'Analysis completed for $source image';
    
    if (hasHighSeverity) {
      title = '⚠️ High Severity Detected';
      message = 'Critical conditions found in $source image';
    } else if (requiresAction) {
      title = '🔍 Action Required';
      message = 'Conditions requiring attention found in $source image';
    }

    return NotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      imageBytes: imageBytes,
      classificationResults: results,
      source: source,
    );
  }

  // Get notification icon based on content
  IconData get notificationIcon {
    if (classificationResults != null) {
      final hasHighSeverity = classificationResults!.any((r) => 
        r.severity == 'High' || r.severity == 'Very High');
      
      if (hasHighSeverity) {
        return Icons.warning;
      } else if (classificationResults!.any((r) => r.requiresAction)) {
        return Icons.info;
      } else {
        return Icons.check_circle;
      }
    }
    return Icons.notifications;
  }

  // Get notification color based on content
  Color get notificationColor {
    if (classificationResults != null) {
      final hasHighSeverity = classificationResults!.any((r) => 
        r.severity == 'High' || r.severity == 'Very High');
      
      if (hasHighSeverity) {
        return Colors.red;
      } else if (classificationResults!.any((r) => r.requiresAction)) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    }
    return Colors.blue;
  }
} 