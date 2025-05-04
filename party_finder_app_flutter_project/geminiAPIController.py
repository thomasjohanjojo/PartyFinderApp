from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
import base64
import io
from PIL import Image
import google.generativeai as genai
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes


# Replace with your actual Gemini API key
GEMINI_API_KEY = "AIzaSyCs6siJ6oETE9SQKD57TXTK9GM6hvdBn_k"  #  <---  IMPORTANT: Replace this!
genai.configure(api_key=GEMINI_API_KEY)


def extract_details_from_poster(image_data):
    """
    Sends an image to the Gemini API and attempts to extract event details.

    Args:
        image_data (bytes): The image data as bytes.

    Returns:
        str: The text extracted by the Gemini API.
    """
    try:
        model = genai.GenerativeModel('gemini-1.5-flash')  #  Using gemini-1.5-flash
        #  Open image from bytes
        img = Image.open(io.BytesIO(image_data))
        response = model.generate_content([
            img,
            "Extract the name of the event, date and time, location, and price of entry from this poster. If the entry is free, please state that."
        ])
        response.resolve()
        return response.text
    except Exception as e:
        return f"An error occurred: {e}"


@app.route('/process_poster', methods=['POST'])
def process_poster():
    """
    Handles POST requests to process an image and extract details using Gemini.
    Expects the image data as base64 in the 'image_data' field of the form data.

    Returns:
        jsonify: A JSON response containing the extracted text or an error message.
    """
    try:
        # Get the image data from the request
        image_data_base64 = request.form.get('image_data')
        print(f"Received image_data_base64: {image_data_base64}") #check
        if not image_data_base64:
            return jsonify({'error': 'No image_data provided', 'status': 'error'}), 400

        # Decode the base64 string to bytes
        image_data = base64.b64decode(image_data_base64)

        # Extract details using the Gemini API
        extracted_text = extract_details_from_poster(image_data)

        # Return the result as JSON
        return jsonify({'extracted_text': extracted_text, 'status': 'success'}), 200

    except Exception as e:
        return jsonify({'error': str(e), 'status': 'error'}), 500



if __name__ == "__main__":
    #  Run the Flask app.  The original code for direct execution is removed,
    #  as the server will handle requests.
    app.run(host='127.0.0.1', port=5000, debug=True)  #  Added debug=True for easier development