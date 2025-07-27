// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pigcam2/main.dart';
import 'package:pigcam2/models/notification_provider.dart';
import 'package:pigcam2/models/classification_history.dart';
import 'package:pigcam2/services/image_classification_service.dart';
import 'package:pigcam2/widgets/classification_result_widget.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NotificationProvider()),
          ChangeNotifierProvider(create: (context) => ClassificationHistoryProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Classification history provider test', (WidgetTester tester) async {
    final historyProvider = ClassificationHistoryProvider();
    
    // Test initial state
    expect(historyProvider.history.length, 0);
    
    // Test adding classification
    final testResult = ClassificationResult(
      label: 'Healthy',
      confidence: 0.95,
      classId: 0,
      description: 'Test description',
      severity: 'None',
      requiresAction: false,
    );
    
    final historyItem = ClassificationHistoryItem(
      id: 'test123',
      imagePath: '/test/path/image.jpg',
      timestamp: DateTime.now(),
      results: [testResult],
      source: 'camera',
    );
    
    historyProvider.addClassification(historyItem);
    expect(historyProvider.history.length, 1);
    expect(historyProvider.history.first.id, 'test123');
    
    // Test filtering
    final cameraHistory = historyProvider.getHistoryBySource('camera');
    expect(cameraHistory.length, 1);
    
    final galleryHistory = historyProvider.getHistoryBySource('gallery');
    expect(galleryHistory.length, 0);
    
    // Test clearing
    historyProvider.clearHistory();
    expect(historyProvider.history.length, 0);
  });

  testWidgets('Classification result widget test', (WidgetTester tester) async {
    final testResults = [
      ClassificationResult(
        label: 'Healthy',
        confidence: 0.95,
        classId: 0,
        description: 'Pigs showing normal, healthy appearance',
        severity: 'None',
        requiresAction: false,
      ),
      ClassificationResult(
        label: 'Skin Changes',
        confidence: 0.85,
        classId: 2,
        description: 'Visible alterations in skin appearance',
        severity: 'Moderate',
        requiresAction: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClassificationResultWidget(
            results: testResults,
            showDetails: true,
          ),
        ),
      ),
    );

    // Verify that results are displayed
    expect(find.text('Classification Results'), findsOneWidget);
    expect(find.text('Healthy'), findsOneWidget);
    expect(find.text('Skin Changes'), findsOneWidget);
  });
}
