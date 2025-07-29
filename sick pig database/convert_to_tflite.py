import tensorflow as tf
import os

# --- Configuration ---
# Path to your saved Keras model
MODEL_PATH = 'pig_disease_detector_model.h5'

# Output path for the TensorFlow Lite model
TFLITE_MODEL_PATH = 'quantized_pig_detector.tflite'

print("--- Starting TensorFlow Lite Model Conversion ---")

# --- 1. Load the Keras model ---
print(f"Loading Keras model from: {MODEL_PATH}")
try:
    model = tf.keras.models.load_model(MODEL_PATH)
    print("Keras model loaded successfully.")
except Exception as e:
    print(f"Error loading Keras model: {e}")
    print("Please ensure 'pig_disease_detector_model.h5' exists in the current directory.")
    exit()

# --- 2. Initialize the TensorFlow Lite Converter ---
# Create a TFLite converter object from the Keras model.
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# --- 3. Apply Quantization (Dynamic Range Quantization) ---
# Dynamic Range Quantization is the simplest form of post-training quantization.
# It quantizes only the weights to 8-bit integers, while activations are dynamically quantized at inference time.
# This significantly reduces model size and speeds up computation with minimal accuracy loss.
print("Applying Dynamic Range Quantization...")
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# For full integer quantization (even smaller model, potentially more accuracy loss),
# you would add:
# converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
# converter.inference_input_type = tf.int8  # Or tf.uint8
# converter.inference_output_type = tf.int8 # Or tf.uint8
# And provide a representative dataset for calibration:
# def representative_data_gen():
#   for input_value in tf.data.Dataset.from_tensor_slices(your_representative_dataset).batch(1).take(100):
#     yield [input_value]
# converter.representative_dataset = representative_data_gen

# --- 4. Convert the model to TFLite format ---
print("Converting model to TFLite...")
tflite_model = converter.convert()

# --- 5. Save the TFLite model ---
print(f"Saving TFLite model to: {TFLITE_MODEL_PATH}")
try:
    with open(TFLITE_MODEL_PATH, 'wb') as f:
        f.write(tflite_model)
    print("TFLite model saved successfully.")
    
    # Print model size for comparison
    original_size = os.path.getsize(MODEL_PATH) / (1024 * 1024) # MB
    tflite_size = os.path.getsize(TFLITE_MODEL_PATH) / (1024 * 1024) # MB
    print(f"Original Keras model size: {original_size:.2f} MB")
    print(f"Quantized TFLite model size: {tflite_size:.2f} MB")

except Exception as e:
    print(f"Error saving TFLite model: {e}")

print("\n--- TensorFlow Lite Model Conversion Complete ---")
print("The 'quantized_pig_detector.tflite' file is now ready for embedded deployment.")
print("Next, you will need to integrate this .tflite file into your ESP32-CAM Arduino project.")

