import google.generativeai as genai
from PIL import Image
import os

# Replace with your actual Gemini API key
GEMINI_API_KEY = "AIzaSyCs6siJ6oETE9SQKD57TXTK9GM6hvdBn_k"
genai.configure(api_key=GEMINI_API_KEY)

def extract_details_from_poster(image_path):
    """
    Sends an image to the Gemini API and attempts to extract event details.

    Args:
        image_path (str): The path to the image file.

    Returns:
        str: The text extracted by the Gemini API.
    """
    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        img = Image.open(image_path)
        response = model.generate_content([img, "Extract the name of the event, date and time, location, and price of entry from this poster. If the entry is free, please state that."])
        response.resolve()
        return response.text
    except Exception as e:
        return f"An error occurred: {e}"

if __name__ == "__main__":
    image_folder = "Images"  # Replace with the actual folder name containing your images
    for filename in os.listdir(image_folder):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            image_file_path = os.path.join(image_folder, filename)
            print(f"Processing image: {image_file_path}")
            extracted_text = extract_details_from_poster(image_file_path)
            print("Extracted details:")
            print(extracted_text)
            print("-" * 20)