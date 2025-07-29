import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping # Import EarlyStopping
import os
import matplotlib.pyplot as plt
import numpy as np

# --- Configuration ---
DATASET_ROOT_PATH = 'C:/Users/Alfred/Desktop/sick pig database'
DATA_SUBFOLDER = 'category'

IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
# Number of epochs to train
EPOCHS = 500 # Reasonably high number, but EarlyStopping will manage it
LEARNING_RATE = 0.0001

# --- 1. Data Loading and Augmentation ---
print("--- Loading and Preprocessing Data ---")

train_val_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode='nearest',
    validation_split=0.2
)

train_generator = train_val_datagen.flow_from_directory(
    os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER),
    target_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='training',
    shuffle=True
)

validation_generator = train_val_datagen.flow_from_directory(
    os.path.join(DATASET_ROOT_PATH, DATA_SUBFOLDER),
    target_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    subset='validation',
    shuffle=False
)

NUM_CLASSES = len(train_generator.class_indices)
print(f"Detected {NUM_CLASSES} classes: {list(train_generator.class_indices.keys())}")
print(f"Found {train_generator.samples} training images belonging to {NUM_CLASSES} classes.")
print(f"Found {validation_generator.samples} validation images belonging to {NUM_CLASSES} classes.")


# --- 2. Model Selection (Transfer Learning with MobileNetV2) ---
print("\n--- Building Model with Transfer Learning ---")

base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(IMAGE_SIZE[0], IMAGE_SIZE[1], 3))
base_model.trainable = False

x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(128, activation='relu')(x)
predictions = Dense(NUM_CLASSES, activation='softmax')(x)

model = Model(inputs=base_model.input, outputs=predictions)

# --- 3. Compile the Model ---
print("\n--- Compiling Model ---")
model.compile(optimizer=Adam(learning_rate=LEARNING_RATE),
              loss='categorical_crossentropy',
              metrics=['accuracy'])

model.summary()

# --- 4. Train the Model ---
print("\n--- Starting Model Training ---")

# Define Early Stopping callback
# monitor='val_loss': Stop when validation loss stops improving
# patience=10: Wait for 10 epochs of no improvement before stopping
# restore_best_weights=True: After stopping, load the model weights from the epoch with the best monitored value (lowest val_loss)
early_stopping = EarlyStopping(monitor='val_loss', patience=20, restore_best_weights=True, verbose=1)

history = model.fit(
    train_generator,
    epochs=EPOCHS,
    validation_data=validation_generator,
    steps_per_epoch=train_generator.samples // BATCH_SIZE,
    validation_steps=validation_generator.samples // BATCH_SIZE,
    callbacks=[early_stopping] # Add the callback here
)

print("\n--- Training Finished ---")

# --- 5. Save the Trained Model ---
print("\n--- Saving Model ---")
model_save_path = 'pig_disease_detector_model.h5'
model.save(model_save_path)
print(f"Model saved to: {model_save_path}")

# --- 6. Plot Training History ---
print("\n--- Plotting Training History ---")
plt.figure(figsize=(12, 4))

plt.subplot(1, 2, 1)
plt.plot(history.history['accuracy'], label='Training Accuracy')
plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
plt.title('Model Accuracy')
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.legend()

plt.subplot(1, 2, 2)
plt.plot(history.history['loss'], label='Training Loss')
plt.plot(history.history['val_loss'], label='Validation Loss')
plt.title('Model Loss')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.legend()

plt.tight_layout()
plt.show()
print("Training history plots displayed.")
 