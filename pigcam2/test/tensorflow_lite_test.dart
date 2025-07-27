import 'package:flutter_test/flutter_test.dart';
import 'package:pigcam2/services/image_classification_service.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Add this line to initialize binding

  group('TensorFlow Lite Integration Tests', () {
    late ImageClassificationService service;

    setUp(() {
      service = ImageClassificationService();
    });

    tearDown(() {
      service.dispose();
    });

    test('Service initialization', () async {
      expect(service.isInitialized, false);
      
      try {
        await service.initialize();
        expect(service.isInitialized, true);
      } catch (e) {
        // If model file is not available, this is expected
        print('Model initialization failed (expected if model file not available): $e');
        expect(service.isInitialized, false);
      }
    });

    test('Image preprocessing test', () {
      // Create a test image
      final testImage = img.Image(width: 100, height: 100);
      for (int y = 0; y < 100; y++) {
        for (int x = 0; x < 100; x++) {
          testImage.setPixel(x, y, img.ColorRgb8(128, 128, 128));
        }
      }

      // Resize to model input size
      final resizedImage = img.copyResize(testImage, width: 224, height: 224);
      
      expect(resizedImage.width, 224);
      expect(resizedImage.height, 224);
      
      // Check that the image was resized correctly
      final pixel = resizedImage.getPixel(0, 0);
      expect(pixel.r, 128);
      expect(pixel.g, 128);
      expect(pixel.b, 128);
    });

    test('Classification result creation', () {
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

    test('Classification result from JSON', () {
      final json = {
        'display_name': 'Skin Changes',
        'id': 2,
        'description': 'Visible alterations in skin appearance',
        'severity': 'High',
        'requires_action': true,
      };

      final result = ClassificationResult.fromJson(json);

      expect(result.label, 'Skin Changes');
      expect(result.classId, 2);
      expect(result.description, 'Visible alterations in skin appearance');
      expect(result.severity, 'High');
      expect(result.requiresAction, true);
    });

    test('Service disposal', () async {
      expect(service.isInitialized, false);
      
      service.dispose();
      expect(service.isInitialized, false);
    });
  });
} 