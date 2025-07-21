import 'package:flutter/material.dart';
import 'package:pigcam2/components/common_app_bar.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class SettingsPage extends StatefulWidget {
  final void Function(ThemeMode themeMode) onThemeModeChanged;
  final void Function(bool enabled) onAnimationsToggled;
  final ThemeMode initialThemeMode;
  final bool initialAnimationsEnabled;

  const SettingsPage({
    super.key,
    required this.onThemeModeChanged,
    required this.onAnimationsToggled,
    required this.initialThemeMode,
    required this.initialAnimationsEnabled,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkModeEnabled;
  late bool _areAnimationsEnabled;
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _isDarkModeEnabled = widget.initialThemeMode == ThemeMode.dark;
    _areAnimationsEnabled = widget.initialAnimationsEnabled;
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {}); // For demo, just rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Settings', showBackButton: true), // Show back button
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: ListView(
        children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  title: Text('Dark Mode', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            value: _isDarkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _isDarkModeEnabled = value;
              });
              widget.onThemeModeChanged(value ? ThemeMode.dark : ThemeMode.light);
                    _showFeedback('Dark mode ${value ? 'enabled' : 'disabled'}');
                  },
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text('Language', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'French', child: Text('French')),
                      DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                        _showFeedback('Language set to $value');
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  title: Text('Enable Notifications', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                      _notificationsEnabled = value;
              });
                    _showFeedback('Notifications ${value ? 'enabled' : 'disabled'}');
            },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 