import 'package:flutter/material.dart';
import 'package:pigcam2/pages/home_page.dart';
import 'package:pigcam2/pages/camera_page.dart';
import 'package:pigcam2/pages/settings_page.dart';
import 'package:pigcam2/pages/notifications_page.dart'; // Import NotificationsPage
import 'package:pigcam2/pages/video_gallery_page.dart'; // Import VideoGalleryPage
import 'package:pigcam2/pages/prediction_history_page.dart'; // Import PredictionHistoryPage
import 'package:pigcam2/models/notification_provider.dart'; // Import NotificationProvider
import 'package:pigcam2/models/classification_history.dart'; // Import ClassificationHistoryProvider
import 'package:animated_background/animated_background.dart';
import 'package:provider/provider.dart'; // Import provider package

class MainScaffold extends StatefulWidget {
  final ThemeMode themeMode;
  final bool areAnimationsEnabled;
  final void Function(ThemeMode) onThemeModeChanged;
  final void Function(bool) onAnimationsToggled;
  const MainScaffold({
    super.key,
    required this.themeMode,
    required this.areAnimationsEnabled,
    required this.onThemeModeChanged,
    required this.onAnimationsToggled,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      CameraPage(ipAddress: ''),
      SettingsPage(
        onThemeModeChanged: widget.onThemeModeChanged,
        onAnimationsToggled: widget.onAnimationsToggled,
        initialThemeMode: widget.themeMode,
        initialAnimationsEnabled: widget.areAnimationsEnabled,
      ),
    ];

    final Brightness brightness = Theme.of(context).brightness;
    final Color particleColor = brightness == Brightness.light
        ? Colors.black.withOpacity(0.5)
        : Colors.white.withOpacity(0.5);

    Widget content = Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          _onItemTapped(index);
        },
        type: BottomNavigationBarType.fixed,
      ),
    );

    if (widget.areAnimationsEnabled) {
      content = AnimatedBackground(
        vsync: this,
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            spawnOpacity: 0.0,
            opacityChangeRate: 0.25,
            minOpacity: 0.1,
            maxOpacity: 0.4,
            spawnMinSpeed: 30.0,
            spawnMaxSpeed: 70.0,
            spawnMinRadius: 7.0,
            spawnMaxRadius: 15.0,
            particleCount: 50,
            baseColor: particleColor,
          ),
        ),
        child: content,
      );
    }

    return content;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _areAnimationsEnabled = true;

  void _setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void _toggleAnimations(bool enabled) {
    setState(() {
      _areAnimationsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PigCam2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF2F2F2F), // gray-dark background
        cardColor: Color(0xFF3F3F3F), // gray-dark card color
        canvasColor: Color(0xFF3F3F3F), // gray-dark canvas color
      ),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => MainScaffold(
          themeMode: _themeMode,
          areAnimationsEnabled: _areAnimationsEnabled,
          onThemeModeChanged: _setThemeMode,
          onAnimationsToggled: _toggleAnimations,
        ),
        '/camera': (context) => CameraPage(ipAddress: ''),
        '/settings': (context) => SettingsPage(
          onThemeModeChanged: _setThemeMode,
          onAnimationsToggled: _toggleAnimations,
          initialThemeMode: _themeMode,
          initialAnimationsEnabled: _areAnimationsEnabled,
        ),
        '/notifications': (context) => const NotificationsPage(),
        '/video_gallery': (context) => const VideoGalleryPage(),
        '/prediction_history': (context) => const PredictionHistoryPage(),
      },
    );
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => ClassificationHistoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
