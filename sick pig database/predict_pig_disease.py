import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np
import os
import matplotlib.pyplot as plt

# --- Configuration ---
# IMPORTANT: This path should point to your 'sick pig database' folder.
DATASET_ROOT_PATH = 'C:/Users/Alfred/Desktop/sick pig database'

# The specific subfolder within DATASET_ROOT_PATH that contains your class folders.
DATA_SUBFOLDER = 'category' # Must match what you used for training

MODEL_PATH = 'pig_disease_detector_model.h5' # Path to your saved model

IMAGE_SIZE = (224, 224) # Must match the size used during training

# --- 1. Load the Trained Model ---
print("--- Loading the Trained Model ---")
try:
    model = tf.keras.models.load_model(MODEL_PATH)
    print(f"Model '{MODEL_PATH}' loaded successfully.")
except Exception as e:
    print(f"Error loading model: {e}")
    print("Please ensure 'pig_disease_detector_model.h5' is in the same directory as this script.")
    exit()

# --- 2. Get Class Names (from your training data) ---
# We need to know the order of classes the model was trained on.
# We can infer this from the directory structure used by ImageDataGenerator.
print("\n--- Inferring Class Names ---")
dummy_datagen = image.ImageDataGenerator(rescale=1./255)
dummy_generator = dummy_datagen.flow_from_directory(
    os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER),
    target_size=IMAGE_SIZE,
    batch_size=1, # Only need 1 for getting class names
    class_mode='categorical',
    shuffle=False
)
class_names = list(dummy_generator.class_indices.keys())
print(f"Inferred {len(class_names)} classes: {class_names}")

# --- 3. Function to Predict on a Single Image ---
def predict_image(img_path):
    print(f"\n--- Predicting for image: {img_path} ---")
    try:
        # Load the image and resize it to the target size
        img = image.load_img(img_path, target_size=IMAGE_SIZE)
        img_array = image.img_to_array(img) # Convert image to numpy array
        img_array = np.expand_dims(img_array, axis=0) # Add batch dimension (1, H, W, C)
        img_array = img_array / 255.0 # Normalize pixel values (0-1)

        # Make prediction
        predictions = model.predict(img_array)
        
        # Get the predicted class index (highest probability)
        predicted_class_index = np.argmax(predictions[0])
        predicted_class_name = class_names[predicted_class_index]
        confidence = predictions[0][predicted_class_index] * 100

        print(f"Predicted Class: {predicted_class_name}")
        print(f"Confidence: {confidence:.2f}%")

        # Display the image with prediction
        plt.imshow(img)
        plt.title(f"Predicted: {predicted_class_name} ({confidence:.2f}%)")
        plt.axis('off')
        plt.show()

    except FileNotFoundError:
        print(f"Error: Image file not found at '{img_path}'.")
        print("Please ensure the path and filename are correct and the file exists.")
    except Exception as e:
        print(f"An error occurred during prediction: {e}")

# --- 4. Example Usage ---
# IMPORTANT: You MUST replace these placeholder filenames with actual image filenames
# from YOUR dataset! Go into the specified folders and find real .jpg or .png files.

# Example 1: Pick an image from 'abnormal secretion'
# Find a real image file in 'C:/Users/Alfred/Desktop/sick pig database/category/abnormal secretion/'
sample_image_path_1 = os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER, 'abnormal secretion', 'abnormal secretion44.jpg') # <--- REPLACE 'example_image_1.jpg' with a real filename!
predict_image(sample_image_path_1)

# Example 2: Pick an image from 'skin changes'
# Find a real image file in 'C:/Users/Alfred/Desktop/sick pig database/category/skin changes/'
sample_image_path_2 = os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER, 'skin changes', 'skin13.jpg') # <--- REPLACE 'example_image_2.jpg' with a real filename!
predict_image(sample_image_path_2)

# Example 3: Pick an image from 'hernia'
# Find a real image file in 'C:/Users/Alfred/Desktop/sick pig database/category/hernia/'
sample_image_path_3 = os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER, 'hernia', 'fig3.jpg') # <--- REPLACE 'example_image_3.jpg' with a real filename!
predict_image(sample_image_path_3)


sample_image_path_4 = os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER, 'cenker', 'centker6.jpg') 
predict_image(sample_image_path_4)

sample_image_path_5 = os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER, 'skin chnages', 'skin6.jpg')  
predict_image(sample_image_path_5)

sample_image_path_6 = os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER, 'Healthy', 'dave.jpg')  
predict_image(sample_image_path_6)

print("\n--- Prediction script finished. ---")
print("Remember to replace the 'example_image_X.jpg' placeholders with actual filenames from your dataset!")
