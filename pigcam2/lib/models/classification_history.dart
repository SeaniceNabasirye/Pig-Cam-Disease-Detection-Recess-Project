import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pigcam2/services/image_classification_service.dart';

class ClassificationHistoryItem {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final List<ClassificationResult> results;
  final String source; // 'camera', 'gallery', 'stream'

  ClassificationHistoryItem({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.results,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'results': results.map((r) => {
        'label': r.label,
        'confidence': r.confidence,
        'classId': r.classId,
        'description': r.description,
        'severity': r.severity,
        'requiresAction': r.requiresAction,
      }).toList(),
      'source': source,
    };
  }

  factory ClassificationHistoryItem.fromJson(Map<String, dynamic> json) {
    return ClassificationHistoryItem(
      id: json['id'],
      imagePath: json['imagePath'],
      timestamp: DateTime.parse(json['timestamp']),
      results: (json['results'] as List).map((r) => ClassificationResult(
        label: r['label'],
        confidence: r['confidence'],
        classId: r['classId'],
        description: r['description'],
        severity: r['severity'],
        requiresAction: r['requiresAction'],
      )).toList(),
      source: json['source'],
    );
  }
}

class ClassificationHistoryProvider extends ChangeNotifier {
  List<ClassificationHistoryItem> _history = [];

  List<ClassificationHistoryItem> get history => List.unmodifiable(_history);

  void addClassification(ClassificationHistoryItem item) {
    _history.insert(0, item); // Add to beginning
    // Keep only last 100 items
    if (_history.length > 100) {
      _history = _history.take(100).toList();
    }
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  List<ClassificationHistoryItem> getHistoryBySource(String source) {
    return _history.where((item) => item.source == source).toList();
  }

  List<ClassificationHistoryItem> getHistoryByDateRange(DateTime start, DateTime end) {
    return _history.where((item) => 
      item.timestamp.isAfter(start) && item.timestamp.isBefore(end)
    ).toList();
  }
} 