import os
import io
import smtplib
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing import image
from flask import Flask, request, jsonify
from PIL import Image # Import PIL for image processing
import datetime # Import datetime for timestamps and cooldown

# --- Flask App Setup ---
app = Flask(__name__)

# --- Configuration ---
MODEL_PATH = 'C:/Users/Alfred/Desktop/sick pig database/pig_disease_detector_model.h5'
DATASET_ROOT_PATH = 'C:/Users/Alfred/Desktop/sick pig database'
DATA_SUBFOLDER = 'category'
IMAGE_SIZE = (224, 224)

# --- Email Configuration ---
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SENDER_EMAIL = "ebajuedward3@gmail.com"
SENDER_PASSWORD = "nyeo quqr bmtv dlxz"
RECIPIENT_EMAILS = ["community.a.i.s.d@gmail.com","seanice877@gmail.com"]

# --- NEW: Alert Cooldown Configuration ---
# Time in seconds before another email for the SAME disease can be sent.
# This prevents spamming if the camera keeps seeing the same sick pig.
ALERT_COOLDOWN_SECONDS = 3600 # 1 hour (3600 seconds).

# --- Global Variables for Model, Class Names, Latest Prediction, and Alert Tracking ---
model = None
class_names = []
latest_prediction_data = {
    "prediction": "No data yet",
    "confidence": "0.00%",
    "timestamp": "N/A",
    "image": None # Store base64 encoded image if needed
}
# --- NEW: Dictionary to track the last alert time for each disease class ---
last_alert_times = {} # Stores { 'disease_name': datetime_object, ... }

# --- Function to Load Model and Class Names ---
def load_model_and_classes():
    global model, class_names
    print("Loading model and inferring class names...")
    try:
        model = tf.keras.models.load_model(MODEL_PATH)
        print("Model loaded successfully.")

        dummy_datagen = image.ImageDataGenerator(rescale=1./255)
        dummy_generator = dummy_datagen.flow_from_directory(
            os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER),
            target_size=IMAGE_SIZE,
            batch_size=1,
            class_mode='categorical',
            shuffle=False
        )
        class_names = list(dummy_generator.class_indices.keys())
        print(f"Inferred {len(class_names)} classes: {class_names}")
    except Exception as e:
        print(f"Error loading model or inferring class names: {e}")
        exit()

# --- Function to Send Email Alert ---
def send_email_alert(subject, message, image_data=None):
    try:
        msg = MIMEMultipart()
        msg['From'] = SENDER_EMAIL
        msg['To'] = ", ".join(RECIPIENT_EMAILS)
        msg['Subject'] = subject

        msg.attach(MIMEText(message, 'plain'))

        if image_data:
            img_part = MIMEImage(image_data, name='detected_pig_image.jpg')
            msg.attach(img_part)

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            server.sendmail(SENDER_EMAIL, RECIPIENT_EMAILS, msg.as_string())
        print("Email alert sent successfully!")
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

# --- Flask Route for Image Inference ---
@app.route('/predict', methods=['POST'])
def predict_image_route():
    global latest_prediction_data, last_alert_times # Allow modification of global variables
    img_bytes = request.get_data()

    if not img_bytes:
        return jsonify({"error": "No image data provided in request body"}), 400

    try:
        img = image.load_img(io.BytesIO(img_bytes), target_size=IMAGE_SIZE)
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = img_array / 255.0

        predictions = model.predict(img_array)
        predicted_class_index = np.argmax(predictions[0])
        predicted_class_name = class_names[predicted_class_index]
        confidence = predictions[0][predicted_class_index] * 100

        response_message = f"Predicted: {predicted_class_name} (Confidence: {confidence:.2f}%)"
        print(response_message)

        # Define your disease classes (excluding 'Healthy' and any 'background' class)
        disease_classes = [name for name in class_names if name != 'Healthy' and name != 'Background' and name != 'Not_Pig']

        # --- NEW: Update latest_prediction_data ---
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        import base64 # Ensure base64 is imported here if not at top level
        img_base64 = None
        try:
            display_img = Image.open(io.BytesIO(img_bytes))
            display_img.thumbnail((320, 240))
            buffered = io.BytesIO()
            display_img.save(buffered, format="JPEG")
            img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')
        except Exception as img_e:
            print(f"Error converting image to base64: {img_e}")
            img_base64 = None

        latest_prediction_data.update({
            "prediction": predicted_class_name,
            "confidence": f"{confidence:.2f}%",
            "timestamp": timestamp,
            "image": img_base64
        })
        # --- END NEW ---

        # --- NEW: Alerting Logic with Cooldown and Higher Threshold ---
        # Check if it's a disease class AND confidence is high enough
        # --- THRESHOLD HERE ---
        REQUIRED_CONFIDENCE_THRESHOLD = 80.0 # <--- INCREASED THRESHOLD 
    

        if predicted_class_name in disease_classes and confidence >= REQUIRED_CONFIDENCE_THRESHOLD:
            current_time = datetime.datetime.now()
            # Check if cooldown for this specific disease has passed
            if predicted_class_name not in last_alert_times or \
               (current_time - last_alert_times[predicted_class_name]).total_seconds() > ALERT_COOLDOWN_SECONDS:
                
                subject = f"Pig Health ALERT: {predicted_class_name} (High Confidence)"
                email_message = f"A pig has been detected with potential symptoms of '{predicted_class_name}'.\n" \
                                f"Confidence: {confidence:.2f}%\n" \
                                f"Time: {timestamp}\n" \
                                f"Please investigate immediately."
                
                if send_email_alert(subject, email_message, image_data=img_bytes):
                    last_alert_times[predicted_class_name] = current_time # Update last alert time
                
            else:
                time_since_last_alert = (current_time - last_alert_times[predicted_class_name]).total_seconds()
                print(f"Alert for '{predicted_class_name}' is on cooldown. Last sent {time_since_last_alert:.0f} seconds ago. Next alert in {ALERT_COOLDOWN_SECONDS - time_since_last_alert:.0f} seconds.")
        else:
            print(f"Prediction: {predicted_class_name} (Confidence: {confidence:.2f}%). No alert sent (not a disease or confidence too low).")
        # --- END NEW ALERTING LOGIC ---

        return jsonify({
            "prediction": predicted_class_name,
            "confidence": f"{confidence:.2f}%",
            "message": response_message
        }), 200

    except Exception as e:
        print(f"Error during prediction or processing: {e}")
        return jsonify({"error": str(e)}), 500

# --- NEW: Endpoint to get the latest prediction ---
@app.route('/latest_prediction', methods=['GET'])
def get_latest_prediction():
    # Return the stored latest prediction data
    return jsonify(latest_prediction_data), 200

# --- Main Execution ---
if __name__ == '__main__':
    # Ensure base64 is imported for image encoding (moved here for clarity)
    import base64 
    load_model_and_classes()
    print("\n--- Starting Flask Server ---")
    app.run(host='0.0.0.0', port=5000)
