import 'package:flutter/material.dart';
import 'package:pigcam2/pages/camera_page.dart';
import 'package:pigcam2/components/common_app_bar.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WiFiSettingsPage extends StatefulWidget {
  const WiFiSettingsPage({super.key});

  @override
  State<WiFiSettingsPage> createState() => _WiFiSettingsPageState();
}

class _WiFiSettingsPageState extends State<WiFiSettingsPage> {
  String _status = 'Not connected';
  final TextEditingController _ssidController = TextEditingController(text: 'ESP32-CAM');
  final TextEditingController _passwordController = TextEditingController();
  bool _scanning = false;
  List<WifiNetwork> _wifiList = [];

  Future<void> _connectToEsp32() async {
    setState(() {
      _status = 'Connecting...';
    });
    try {
      bool connected = await WiFiForIoTPlugin.connect(
        _ssidController.text,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        security: _passwordController.text.isEmpty ? NetworkSecurity.NONE : NetworkSecurity.WPA,
        joinOnce: true,
      );
      if (!mounted) return;
      
      if (connected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CameraPage()),
        );
      } else {
        setState(() {
          _status = 'Failed to connect.';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _scanForWifi() async {
    setState(() {
      _scanning = true;
      _wifiList = [];
    });
    try {
      List<WifiNetwork>? networks = await WiFiForIoTPlugin.loadWifiList();
      setState(() {
        _wifiList = networks ?? [];
        _scanning = false;
      });
      // Auto-connect to ESP32-CAM if found
      WifiNetwork? esp32;
      for (final n in _wifiList) {
        if ((n.ssid ?? '').toLowerCase().contains('esp32')) {
          esp32 = n;
          break;
        }
      }
      if (esp32 != null && (esp32.ssid ?? '').isNotEmpty) {
        setState(() {
          _ssidController.text = esp32!.ssid!;
          _status = 'ESP32-CAM found. Connecting...';
        });
        await _connectToEsp32();
      }
    } catch (e) {
      setState(() {
        _status = 'Scan error: $e';
        _scanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'WiFi Settings', showBackButton: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Connect to ESP32-CAM WiFi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ssidController,
                decoration: const InputDecoration(
                  labelText: 'ESP32-CAM SSID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'WiFi Password (leave blank if open)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.wifi),
                label: const Text('Connect'),
                onPressed: _connectToEsp32,
              ),
              const SizedBox(height: 20),
              Text(_status, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
              const Text(
                'Note: You must grant location and WiFi permissions for this to work on Android.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 