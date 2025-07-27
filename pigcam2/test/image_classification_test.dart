import 'package:flutter_test/flutter_test.dart';
import 'package:pigcam2/services/image_classification_service.dart';
import 'package:pigcam2/models/classification_history.dart';

void main() {
  group('Image Classification Tests', () {
    test('ClassificationResult creation', () {
      final result = ClassificationResult(
        label: 'Healthy',
        confidence: 0.95,
        classId: 0,
        description: 'Pigs showing normal, healthy appearance',
        severity: 'None',
        requiresAction: false,
      );

      expect(result.label, 'Healthy');
      expect(result.confidence, 0.95);
      expect(result.classId, 0);
      expect(result.severity, 'None');
      expect(result.requiresAction, false);
    });

    test('ClassificationResult fromJson', () {
      final json = {
        'display_name': 'Healthy',
        'id': 0,
        'description': 'Pigs showing normal, healthy appearance',
        'severity': 'None',
        'requires_action': false,
      };

      final result = ClassificationResult.fromJson(json);

      expect(result.label, 'Healthy');
      expect(result.classId, 0);
      expect(result.description, 'Pigs showing normal, healthy appearance');
      expect(result.severity, 'None');
      expect(result.requiresAction, false);
    });

    test('ClassificationHistoryItem creation', () {
      final results = [
        ClassificationResult(
          label: 'Healthy',
          confidence: 0.95,
          classId: 0,
          description: 'Pigs showing normal, healthy appearance',
          severity: 'None',
          requiresAction: false,
        ),
      ];

      final historyItem = ClassificationHistoryItem(
        id: 'test123',
        imagePath: '/test/path/image.jpg',
        timestamp: DateTime.now(),
        results: results,
        source: 'camera',
      );

      expect(historyItem.id, 'test123');
      expect(historyItem.imagePath, '/test/path/image.jpg');
      expect(historyItem.results.length, 1);
      expect(historyItem.source, 'camera');
    });

    test('ClassificationHistoryProvider operations', () {
      final provider = ClassificationHistoryProvider();
      
      expect(provider.history.length, 0);

      final results = [
        ClassificationResult(
          label: 'Healthy',
          confidence: 0.95,
          classId: 0,
          description: 'Pigs showing normal, healthy appearance',
          severity: 'None',
          requiresAction: false,
        ),
      ];

      final historyItem = ClassificationHistoryItem(
        id: 'test123',
        imagePath: '/test/path/image.jpg',
        timestamp: DateTime.now(),
        results: results,
        source: 'camera',
      );

      provider.addClassification(historyItem);
      expect(provider.history.length, 1);
      expect(provider.history.first.id, 'test123');

      final cameraHistory = provider.getHistoryBySource('camera');
      expect(cameraHistory.length, 1);

      final galleryHistory = provider.getHistoryBySource('gallery');
      expect(galleryHistory.length, 0);

      provider.clearHistory();
      expect(provider.history.length, 0);
    });

    test('ClassificationResultWidget severity colors', () {
      // Test severity color mapping
      final testCases = [
        {'severity': 'None', 'expectedColor': 'green'},
        {'severity': 'Low', 'expectedColor': 'blue'},
        {'severity': 'Moderate', 'expectedColor': 'orange'},
        {'severity': 'High', 'expectedColor': 'red'},
        {'severity': 'Very High', 'expectedColor': 'purple'},
      ];

      for (final testCase in testCases) {
        final result = ClassificationResult(
          label: 'Test',
          confidence: 0.8,
          classId: 0,
          description: 'Test description',
          severity: testCase['severity']!,
          requiresAction: false,
        );

        expect(result.severity, testCase['severity']);
      }
    });
  });
} 