import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Your Flask Server's IP and Port
const String flaskServerIp = '10.10.168.48'; // Your PC's IP
const int flaskServerPort = 5000;

class CameraStreamWidget extends StatefulWidget {
  @override
  State<CameraStreamWidget> createState() => _CameraStreamWidgetState();
}

class _CameraStreamWidgetState extends State<CameraStreamWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('http://$flaskServerIp:$flaskServerPort/video_feed'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

