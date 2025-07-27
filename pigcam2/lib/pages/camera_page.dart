import 'package:flutter/material.dart';
import 'package:pigcam2/widget/mjpeg_camera_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pigcam2/services/image_classification_service.dart';
import 'package:pigcam2/widgets/classification_result_widget.dart';
import 'package:pigcam2/widgets/platform_image_widget.dart';
import 'package:pigcam2/models/classification_history.dart';
import 'package:pigcam2/models/notification_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class CameraPage extends StatefulWidget {
  final String ipAddress;

  const CameraPage({Key? key, required this.ipAddress}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isCameraStarted = false;
  bool _isClassifying = false;
  List<ClassificationResult>? _lastResults;
  File? _capturedImage;
  Uint8List? _capturedImageBytes; // Add this for web compatibility
  
  late ImageClassificationService _classificationService;
  late ImagePicker _imagePicker;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _classificationService = ImageClassificationService();
    _imagePicker = ImagePicker();
    
    try {
      await _classificationService.initialize();
      await _initializeCamera();
    } catch (e) {
      print('Error initializing services: $e');
      _showErrorSnackBar('Failed to initialize services: $e');
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
      }
    }
  }

  void _toggleCamera() {
    setState(() {
      _isCameraStarted = !_isCameraStarted;
    });
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showErrorSnackBar('Camera not available');
      return;
    }

    try {
      setState(() {
        _isClassifying = true;
      });

      final XFile image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      setState(() {
        _capturedImage = imageFile;
        _capturedImageBytes = imageBytes;
      });

      // Automatically classify the captured image
      await _classifyImage(imageFile, 'camera');
    } catch (e) {
      _showErrorSnackBar('Failed to capture image: $e');
    } finally {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _isClassifying = true;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        
        setState(() {
          _capturedImage = imageFile;
          _capturedImageBytes = imageBytes;
        });

        // Don't automatically classify gallery images - user must press classify button
        _showInfoSnackBar('Image selected. Press "Classify" to analyze.');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    } finally {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  Future<void> _classifyCurrentImage() async {
    if (_capturedImage == null) {
      _showErrorSnackBar('No image to classify');
      return;
    }

    try {
      setState(() {
        _isClassifying = true;
      });

      await _classifyImage(_capturedImage!, 'gallery');
    } catch (e) {
      _showErrorSnackBar('Classification failed: $e');
    } finally {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  Future<void> _classifyImage(File imageFile, String source) async {
    try {
      final results = await _classificationService.classifyImage(imageFile);
      
      setState(() {
        _lastResults = results;
      });

      // Add to history
      final historyProvider = Provider.of<ClassificationHistoryProvider>(context, listen: false);
      final historyItem = ClassificationHistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imageFile.path,
        timestamp: DateTime.now(),
        results: results,
        source: source,
      );
      historyProvider.addClassification(historyItem);

      // Add notification
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.addClassificationNotification(
        results: results,
        source: source,
        imageBytes: _capturedImageBytes,
      );

      if (results.isNotEmpty) {
        _showSuccessSnackBar('Classification completed! Found ${results.length} condition(s)');
      } else {
        _showInfoSnackBar('No conditions detected above threshold');
      }
    } catch (e) {
      _showErrorSnackBar('Classification failed: $e');
    }
  }

  Future<void> _classifyStreamFrame() async {
    // This would capture a frame from the MJPEG stream and classify automatically
    try {
      setState(() {
        _isClassifying = true;
      });

      // Simulate capturing a frame from the stream
      // In a real implementation, this would capture the current frame from the MJPEG stream
      await Future.delayed(Duration(milliseconds: 500)); // Simulate processing time
      
      // For now, we'll show a placeholder message
      _showInfoSnackBar('Stream classification feature coming soon!');
      
      // TODO: Implement actual stream frame capture and classification
      // final streamFrame = await _captureStreamFrame();
      // await _classifyImage(streamFrame, 'stream');
      
    } catch (e) {
      _showErrorSnackBar('Failed to classify stream frame: $e');
    } finally {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera & Classification'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/prediction_history');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera/Stream Section
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isCameraStarted
                    ? MjpegCameraWidget(
                        streamUrl: 'http://${widget.ipAddress}:81/stream',
                      )
                    : _cameraController != null && _cameraController!.value.isInitialized
                        ? CameraPreview(_cameraController!)
                        : Container(
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Camera Ready',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isClassifying ? null : _toggleCamera,
                  icon: Icon(_isCameraStarted ? Icons.stop : Icons.play_arrow),
                  label: Text(_isCameraStarted ? 'Stop' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCameraStarted ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isClassifying || _cameraController == null ? null : _captureImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Capture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isClassifying ? null : _pickImageFromGallery,
                  icon: Icon(Icons.photo_library),
                  label: Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isClassifying ? null : _classifyStreamFrame,
                  icon: Icon(Icons.analytics),
                  label: Text('Stream'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: (_capturedImage != null && !_isClassifying) ? _classifyCurrentImage : null,
                  icon: Icon(Icons.analytics),
                  label: Text('Classify'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (_isClassifying)
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 16),
                  Text('Classifying image...'),
                ],
              ),
            ),

          // Classification Results
          if (_lastResults != null)
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.all(8),
                child: ClassificationResultWidget(
                  results: _lastResults!,
                  showDetails: true,
                ),
              ),
            ),

          // Captured Image Preview
          if (_capturedImage != null && _capturedImageBytes != null)
            Container(
              height: 100,
              margin: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: PlatformImageWidget(
                          imageFile: _capturedImage,
                          imageBytes: _capturedImageBytes,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _capturedImage = null;
                        _capturedImageBytes = null;
                        _lastResults = null;
                      });
                    },
                    icon: Icon(Icons.close),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _classificationService.dispose();
    super.dispose();
  }
}
