# 🐷 Pig Disease Detection System

An integrated machine learning-based system for detecting pig diseases using image classification. Designed to support farmers with real-time monitoring, automated alerts, and mobile accessibility.

---

## 🧠 System Architecture

- **ESP32-CAM**: Captures live images of pigs and streams video feed to the mobile app. Also sends snapshots to the Flask server for disease detection.
- **Flask API Server**: Hosts the trained machine learning model. Receives images from the ESP32-CAM, performs inference, and triggers alerts.
- **Flutter Mobile App**: Provides farmers with a live video feed from the ESP32-CAM and displays disease alerts in real time.
- **Email Alert System**: Sends notifications when a disease is detected with high confidence.

---

## 🚀 Features

- Real-time pig monitoring via mobile app
- Automated disease detection using image classification
- Email alerts for early intervention
- Lightweight design suitable for embedded deployment

---

## 📦 Technologies Used

- ESP32-CAM (IoT device)
- Flask (Python backend)
- TensorFlow / PyTorch (ML model)
- Flutter (mobile frontend)
- SMTP (email notifications)

---

## 📁 Project Structure

THE FILE IN THIS GITHUB IS FOR THE FLUTTER APPLICATION(PIG-CAM-DISEASE-DETECTION-RECESS-PROJECT)

Launch the Flutter App

Open the Flutter project in your IDE (e.g., VS Code or Android Studio).
Run the app on your mobile device.

The app will:

   -Display live feed from ESP32-CAM
   
   -Show disease alerts received from the Flask server

THESE FILES LABELLED BELOW ARE IN THE SICK-PIG-DATABASE(WHICH IS THE PRE-TRAINED MODEL)

| File | Purpose |
|------|---------|
| `train_pig_detector.py` | Train a MobileNetV2-based model on pig disease images |
| `convert_to_tflite.py` | Convert the trained model to TensorFlow Lite format |
| `inference_server.py` | Run a Flask API for real-time inference and email alerts |
| `predict_pig_disease.py` | Perform local predictions on individual images |

---

## 🚀 Setup Instructions

NOTE:

-To download Tensorflow, your python version must be between 3.8 - 3.12

-It also needs you to install CONDA(ANACONDA PROMPT) and create a virtual environment

### 1. Clone the Repository
```bash (TERMINAL)
git clone https://github.com/SeaniceNabasirye/Pig-Cam-Disease-Detection-Recess-Project
cd Pig-Cam-Disease-Detection-Recess-Project
pip install tensorflow flask matplotlib pillow numpy
