import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For list extensions like firstWhereOrNull
import './notification_model.dart';
import 'package:pigcam2/services/image_classification_service.dart';
import 'dart:typed_data';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => UnmodifiableListView(_notifications);
  int get unreadCount => _unreadCount;

  // New list to store captured images for gallery
  final List<Uint8List> _capturedImages = [];

  List<Uint8List> get capturedImages => List.unmodifiable(_capturedImages);

  // New list to store prediction history
  final List<Map<String, dynamic>> _predictionHistory = [];

  List<Map<String, dynamic>> get predictionHistory => List.unmodifiable(_predictionHistory);

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // Add to the beginning so newest is first
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void markNotificationAsRead(String notificationId) {
    final notification = _notifications.firstWhereOrNull((n) => n.id == notificationId);
    if (notification != null && !notification.isRead) {
      notification.isRead = true;
      _unreadCount--;
      notifyListeners();
    }
  }

  // Method to simulate adding a notification from ESP32-CAM image capture
  void addImageCaptureNotification(Uint8List imageBytes) {
    addNotification(
      NotificationModel.imageCaptureNotification(imageBytes: imageBytes),
    );
    // Also add to captured images list
    _capturedImages.insert(0, imageBytes);
    notifyListeners();
  }

  // Method to add classification notification
  void addClassificationNotification({
    required List<ClassificationResult> results,
    required String source,
    Uint8List? imageBytes,
    String? customTitle,
    String? customMessage,
  }) {
    addNotification(
      NotificationModel.classificationNotification(
        results: results,
        source: source,
        imageBytes: imageBytes,
        customTitle: customTitle,
        customMessage: customMessage,
      ),
    );
    notifyListeners();
  }

  void addPredictionHistory(Map<String, dynamic> prediction) {
    _predictionHistory.insert(0, prediction);
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  void toggleReadStatus(String notificationId) {
    final notification = _notifications.firstWhereOrNull((n) => n.id == notificationId);
    if (notification != null) {
      notification.isRead = !notification.isRead;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }
} 