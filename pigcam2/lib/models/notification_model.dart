import 'package:flutter/material.dart';
import 'dart:typed_data';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final Uint8List? imageBytes;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.imageBytes,
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
} 