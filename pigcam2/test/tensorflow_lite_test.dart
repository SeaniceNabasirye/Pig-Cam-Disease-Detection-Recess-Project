import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../lib/services/image_classification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter binding for tests
  
  group('TensorFlow Lite Model Tests', () {
    late ImageClassificationService service;

    setUp(() {
      service = ImageClassificationService();
    });

    tearDown(() {
      service.dispose();
    });

    test('Model initialization', () async {
      // Test that the model can be initialized
      await service.initialize();
      expect(service.isInitialized, isTrue);
    });

    test('Model file exists', () async {
      // Test that the model file is accessible
      final modelData = await rootBundle.load('assets/model/quantized_pig_detector.tflite');
      expect(modelData, isNotNull);
      expect(modelData.lengthInBytes, greaterThan(0));
    });

    test('Labels file exists', () async {
      // Test that the labels file is accessible
      final labelsString = await rootBundle.loadString('assets/model/labels.json');
      expect(labelsString, isNotEmpty);
      
      final labelsData = jsonDecode(labelsString);
      expect(labelsData['classes'], isNotNull);
      expect(labelsData['classes'], isA<List>());
      expect(labelsData['classes'].length, greaterThan(0));
    });

    test('Image classification with test image', () async {
      await service.initialize();
      
      // Create a test image (224x224 pixels)
      final testImage = img.Image(width: 224, height: 224);
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          // Create a simple test pattern
          final r = (x * 255 / 224).round();
          final g = (y * 255 / 224).round();
          final b = 128;
          testImage.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
      
      // Save test image to temporary file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_image.jpg');
      testFile.writeAsBytesSync(img.encodeJpg(testImage));
      
      try {
        // Run classification
        final results = await service.classifyImage(testFile);
        
        // Verify results
        expect(results, isNotNull);
        expect(results, isA<List<ClassificationResult>>());
        
        // If we get results, verify their structure
        if (results.isNotEmpty) {
          final result = results.first;
          expect(result.label, isNotEmpty);
          expect(result.confidence, greaterThanOrEqualTo(0.0));
          expect(result.confidence, lessThanOrEqualTo(1.0));
          expect(result.classId, greaterThanOrEqualTo(0));
          expect(result.description, isNotEmpty);
          expect(result.severity, isNotEmpty);
        }
        
        print('✅ Classification test passed with ${results.length} results');
        for (final result in results) {
          print('  - ${result.label}: ${(result.confidence * 100).toStringAsFixed(1)}%');
        }
      } finally {
        // Cleanup
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }
    });

    test('Error handling for invalid image', () async {
      await service.initialize();
      
      // Create an invalid image file
      final tempDir = Directory.systemTemp;
      final invalidFile = File('${tempDir.path}/invalid.txt');
      invalidFile.writeAsStringSync('This is not an image');
      
      try {
        await expectLater(
          service.classifyImage(invalidFile),
          throwsA(isA<Exception>()),
        );
      } finally {
        if (await invalidFile.exists()) {
          await invalidFile.delete();
        }
      }
    });
  });
} 