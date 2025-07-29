import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class MjpegCameraWidget extends StatefulWidget {
  final String streamUrl;
  final double? aspectRatio;
  final double? width;
  final double? height;
  final BoxFit fit;

  const MjpegCameraWidget({
    Key? key,
    required this.streamUrl,
    this.aspectRatio,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<MjpegCameraWidget> createState() => _MjpegCameraWidgetState();
}

class _MjpegCameraWidgetState extends State<MjpegCameraWidget> {
  bool _isLoadingStream = true;
  bool _isStreamActive = false;
  String _errorMessage = '';
  final GlobalKey _mjpegKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _testAndStartStreaming();
  }

  void _testAndStartStreaming() async {
    setState(() {
      _isLoadingStream = true;
      _errorMessage = '';
      _isStreamActive = false;
    });
    // Optionally, you could add a real network test here
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoadingStream = false;
      _isStreamActive = true;
    });
  }

  void _refreshStream() {
    setState(() {
      _isLoadingStream = true;
      _errorMessage = '';
      _isStreamActive = false;
    });
    _testAndStartStreaming();
  }

  Widget _buildVideoWidget() {
    if (_isLoadingStream) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white54),
          const SizedBox(height: 16),
          const Icon(Icons.videocam, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'Connecting to Live Camera Feed...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            widget.streamUrl,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'Camera Connection Failed',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _testAndStartStreaming,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Connection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }

    if (_isStreamActive) {
      debugPrint('🎥 Attempting to display MJPEG stream: ${widget.streamUrl}');
      return Mjpeg(
        key: _mjpegKey,
        isLive: true,
        stream: widget.streamUrl,
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        fit: widget.fit,
        loading: (context) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white54),
              SizedBox(height: 10),
              Text(
                'Loading video stream...',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ],
          ),
        ),
        error: (context, error, stack) {
          debugPrint('🚨 MJPEG Stream Error: $error');
          debugPrint('Stack trace: $stack');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _errorMessage = error.toString();
                _isStreamActive = false;
              });
            }
          });
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.red, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Stream Error',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'URL: ${widget.streamUrl}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _refreshStream,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
        timeout: const Duration(seconds: 30),
      );
    }

    // Default state
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.videocam, size: 64, color: Colors.white54),
        const SizedBox(height: 16),
        const Text(
          'Live Camera Feed',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        Text(
          widget.streamUrl,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _testAndStartStreaming,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Stream'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final backgroundColor = brightness == Brightness.light ? Color(0xFF2F2F2F) : Color(0xFF3F3F3F); // gray-dark in light mode, gray in dark mode

    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? 16 / 9,
      child: Container(
        color: backgroundColor,
        alignment: Alignment.center,
        child: _buildVideoWidget(),
      ),
    );
  }
} 