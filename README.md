# PigCam2 - Pig Health Monitoring App

A Flutter application for monitoring pig health using computer vision and machine learning. The app can classify pig images to detect various health conditions and provide real-time monitoring through ESP32-CAM integration.

## Features

### 🎯 Core Functionality
- **Real-time ESP32-CAM Stream**: View live video feed from ESP32-CAM modules
- **Image Classification**: Analyze pig images for health conditions using TensorFlow Lite
- **Multiple Input Sources**: 
  - Device camera capture
  - Gallery image selection
  - ESP32-CAM stream frames
- **Health Condition Detection**: Identifies 6 different pig health conditions:
  - Healthy (normal appearance)
  - Abnormal Secretion (discharge from eyes, nose, ears)
  - Skin Changes (rashes, lesions, scabs)
  - Hernia (abdominal protrusion)
  - Cancer (malignant growths)
  - Skin Changes Alternative (environmental factors)

### 📱 User Interface
- **Modern Material Design**: Clean, intuitive interface with dark/light theme support
- **Real-time Results**: Instant classification results with confidence scores
- **History Management**: View and filter classification history
- **Severity Indicators**: Color-coded severity levels and action requirements
- **Responsive Design**: Works on various screen sizes and orientations

### 🔧 Technical Features
- **TensorFlow Lite Integration**: On-device machine learning inference
- **Image Processing**: Automatic image preprocessing and normalization
- **State Management**: Provider pattern for efficient state management
- **Permission Handling**: Proper camera and storage permissions
- **Error Handling**: Comprehensive error handling and user feedback

## Installation

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator (API level 21+)

### Setup
1. Clone the repository:
```bash
git clone <repository-url>
cd pigcam2
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure ESP32-CAM:
   - Set up your ESP32-CAM module
   - Note the IP address for stream access
   - Ensure the camera is accessible at `http://<IP>:81/stream`

4. Run the application:
```bash
flutter run
```

## Usage

### Camera & Classification
1. **Start Camera**: Tap the "Start" button to begin camera preview
2. **Capture Image**: Use the "Capture" button to take a photo
3. **Select from Gallery**: Use the "Gallery" button to choose existing images
4. **View Results**: Classification results appear below the camera view
5. **History**: Access classification history via the history icon

### ESP32-CAM Integration
1. **Connect to Stream**: Enter the ESP32-CAM IP address
2. **Start Stream**: Toggle the stream on/off
3. **Classify Frames**: Use the "Classify" button for stream analysis

### History Management
- **View History**: Access all previous classifications
- **Filter Results**: Filter by source (camera, gallery, stream) or severity
- **Clear History**: Remove all classification records
- **Export Results**: Share classification results (coming soon)

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── services/
│   └── image_classification_service.dart  # ML classification logic
├── models/
│   ├── classification_history.dart    # History data models
│   └── notification_provider.dart     # Notification management
├── pages/
│   ├── camera_page.dart               # Main camera & classification UI
│   ├── prediction_history_page.dart   # History viewing
│   └── ...                           # Other app pages
├── widgets/
│   ├── classification_result_widget.dart  # Results display
│   └── mjpeg_camera_widget.dart      # ESP32 stream widget
└── components/
    └── ...                           # Reusable UI components
```

## Configuration

### Model Files
Place your TensorFlow Lite model and labels in:
```
assets/model/
├── quantized_pig_detector.tflite     # TensorFlow Lite model
└── labels.json                       # Classification labels
```

### Android Permissions
The app automatically requests necessary permissions:
- Camera access
- Storage access
- Network access

## Development

### Adding New Health Conditions
1. Update `assets/model/labels.json` with new condition definitions
2. Retrain the TensorFlow model with new classes
3. Update the model file in `assets/model/`

### Customizing the UI
- Modify `lib/widgets/classification_result_widget.dart` for result display
- Update `lib/pages/camera_page.dart` for camera interface
- Customize themes in `lib/main.dart`

### Testing
Run the test suite:
```bash
flutter test
```

## Troubleshooting

### Common Issues
1. **Camera not working**: Check device permissions
2. **ESP32 stream not loading**: Verify IP address and network connectivity
3. **Classification errors**: Ensure model files are properly placed
4. **Build errors**: Run `flutter clean` and `flutter pub get`

### Performance Optimization
- Use appropriate image resolution for classification
- Consider model quantization for faster inference
- Implement caching for repeated classifications

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- TensorFlow Lite for on-device machine learning
- ESP32-CAM community for hardware integration
- Flutter team for the excellent framework
- Pig farming community for domain expertise

## Support

For support and questions:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the documentation

---

**Note**: This is a demo version with simulated classification results. For production use, integrate with a properly trained TensorFlow Lite model.
