import 'package:flutter/material.dart';
import 'package:pigcam2/components/common_app_bar.dart';
import 'dart:async'; // Import for Timer
import 'package:marquee/marquee.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:pigcam2/models/notification_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final PageController _verticalPageController = PageController(); // New controller for vertical carousel
  late Timer _timer;
  int _currentPage = 0;
  final List<String> _imageAssets = [
    'assets/images/pig1.jpg',
    'assets/images/pig2.jpg',
    'assets/images/pig3.jpg',
  ];

  final List<String> _imageDescriptions = [
    'A happy pig enjoying the sun.',
    'This pig is curious about its surroundings.',
    'A sleepy pig taking a nap.',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _imageAssets.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _verticalPageController.dispose(); // Dispose the new controller
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {}); // For demo, just rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Home Page'),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Home Page (already there)
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Camera Page
                Navigator.pushReplacementNamed(context, '/camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings Page
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 25.0, left: 15.0, right: 15.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: SizedBox(
                  height: 200, // Horizontal carousel height
                child: PageView(
                    controller: _pageController, // Horizontal carousel controller
                  children: _imageAssets.map((assetPath) {
                    return Image.asset(assetPath, fit: BoxFit.cover);
                  }).toList(),
                ),
              ),
            ),
          ),
            const SizedBox(height: 25), // Space below horizontal carousel
          Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.camera_alt, color: Colors.blue),
                  title: Text('Camera'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/camera');
                  },
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.settings, color: Colors.blue),
                  title: Text('Settings'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/settings');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Most recent notifications
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final notifications = notificationProvider.notifications.take(3).toList();
              if (notifications.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('No recent notifications.'),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Recent Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...notifications.map((n) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(n.iconData ?? Icons.notifications),
                          title: Text(n.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.message),
                              const SizedBox(height: 4),
                              Text(
                                '${n.timestamp.toLocal().toString().split('.')[0]}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                      child: const Text('View All'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
        ],
        ),
      ),
    );
  }
} 