import 'package:flutter/material.dart';
import 'package:pigcam2/widget/mjpeg_camera_widget.dart';
import '../widgets/mjpeg_camera_widget.dart';

class CameraPage extends StatefulWidget {
  final String ipAddress;

  const CameraPage({Key? key, required this.ipAddress}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isCameraStarted = false;

  void _toggleCamera() {
    setState(() {
      _isCameraStarted = !_isCameraStarted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Stream'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isCameraStarted)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                width: MediaQuery.of(context).size.width,
                child: MjpegCameraWidget(
                  streamUrl: 'http://${widget.ipAddress}:81/stream', // ESP32-CAM stream
                ),
              )
            else
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                width: MediaQuery.of(context).size.width,
                color: Colors.black12,
                alignment: Alignment.center,
                child: Text(
                  'Camera is stopped',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleCamera,
              child: Text(_isCameraStarted ? 'Stop Camera' : 'Start Camera'),
            ),
          ],
        ),
      ),
    );
  }
}
