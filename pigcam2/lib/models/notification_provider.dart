import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For list extensions like firstWhereOrNull
import './notification_model.dart';
import 'dart:typed_data';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => UnmodifiableListView(_notifications);
  int get unreadCount => _unreadCount;

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