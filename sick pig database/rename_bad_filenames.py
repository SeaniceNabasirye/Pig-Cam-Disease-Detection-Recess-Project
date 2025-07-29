import os
import re
import shutil

# IMPORTANT: Set this to the root of your dataset where 'category' and 'condition' are
DATASET_ROOT_PATH = 'C:/Users/Alfred/Desktop/sick pig database' # CONFIRMED PATH

def rename_problematic_files(root_dir):
    """
    Scans all subdirectories for files with problematic URL-like names
    and renames them to a simpler, sequential format within their current folder.
    """
    print(f"Starting scan for problematic filenames in: {root_dir}")
    renamed_count = 0

    # Regex to identify URL-like patterns or excessively long names
    # This pattern looks for 'src=', 'http', 'https', or very long sequences of non-alphanumeric chars
    # You might need to adjust this regex if it's too aggressive or not catching all cases.
    problematic_pattern = re.compile(r'(src=|http|https|%|&|=|\?|\s{2,})', re.IGNORECASE)

    for subdir, _, files in os.walk(root_dir):
        # Skip any newly created quarantine/temp folders if they exist
        if 'quarantined_bad_images' in subdir or 'temp_renamed_files' in subdir:
            continue

        file_counter = 0 # Counter for sequential naming within each folder
        for file_name in files:
            full_old_path = os.path.join(subdir, file_name)

            # Check if the filename matches the problematic pattern OR is excessively long
            # An arbitrary length, e.g., > 100 characters, can also indicate a problem.
            if problematic_pattern.search(file_name) or len(file_name) > 100:
                # Determine new file extension
                _, ext = os.path.splitext(file_name)
                if not ext: # If no extension, try to guess or default to .jpg
                    ext = '.jpg' # Default extension if none found

                # Create a new, clean name
                new_file_name = f"renamed_image_{file_counter}{ext}"
                full_new_path = os.path.join(subdir, new_file_name)

                # Ensure the new name doesn't already exist (unlikely with sequential counter)
                while os.path.exists(full_new_path):
                    file_counter += 1
                    new_file_name = f"renamed_image_{file_counter}{ext}"
                    full_new_path = os.path.join(subdir, new_file_name)

                try:
                    os.rename(full_old_path, full_new_path)
                    print(f"Renamed: '{file_name}' -> '{new_file_name}' in '{subdir}'")
                    renamed_count += 1
                except Exception as e:
                    print(f"Error renaming '{file_name}' to '{new_file_name}': {e}")
            
            file_counter += 1 # Increment counter for next file in this subdir

    print(f"\n--- Filename Renaming Summary ---")
    print(f"Total problematic files renamed: {renamed_count}")
    print("Please try running your training script again.")

if __name__ == "__main__":
    # Ensure the root path is correct before running
    if not os.path.isdir(DATASET_ROOT_PATH):
        print(f"Error: DATASET_ROOT_PATH '{DATASET_ROOT_PATH}' does not exist.")
        print("Please update DATASET_ROOT_PATH in the script to your actual dataset location.")
    else:
        rename_problematic_files(DATASET_ROOT_PATH)

