import 'package:flutter/material.dart';
import 'package:pigcam2/components/common_app_bar.dart';
import 'dart:async'; // Import for Timer
import 'package:marquee/marquee.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:pigcam2/models/notification_provider.dart';
import 'package:pigcam2/models/notification_model.dart'; // Added import for NotificationModel

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

  Widget _buildClassificationNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: notification.notificationColor.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: notification.notificationColor.withOpacity(0.1),
            child: Icon(
              notification.notificationIcon,
              color: notification.notificationColor,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: notification.notificationColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.source, size: 12, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Source: ${notification.source ?? 'Unknown'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                '${notification.timestamp.toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: notification.classificationResults != null
              ? Chip(
                  label: Text('${notification.classificationResults!.length} results'),
                  backgroundColor: notification.notificationColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: notification.notificationColor),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: Icon(notification.notificationIcon, color: Colors.grey),
        title: Text(notification.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              '${notification.timestamp.toLocal().toString().split('.')[0]}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt, color: Colors.blue),
                label: const Text('Camera'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/camera');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 4,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings, color: Colors.blue),
                label: const Text('Settings'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/settings');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 4,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Most recent notifications
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final notifications = notificationProvider.notifications.take(5).toList();
              if (notifications.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('No recent notifications.'),
                );
              }
              
              // Separate classification notifications from others
              final classificationNotifications = notifications.where((n) => n.classificationResults != null).toList();
              final otherNotifications = notifications.where((n) => n.classificationResults == null).toList();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Classification notifications (show first if any)
                  if (classificationNotifications.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, left: 16.0),
                      child: Text(
                        '🔍 Recent Classifications',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                    ...classificationNotifications.map((n) => _buildClassificationNotificationCard(n)),
                    const SizedBox(height: 16),
                  ],
                  
                  // Other notifications
                  if (otherNotifications.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, left: 16.0),
                      child: Text(
                        '📢 Other Notifications',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...otherNotifications.map((n) => _buildNotificationCard(n)),
                  ],
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                      child: const Text('View All Notifications'),
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