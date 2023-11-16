import os
import fitz  # PyMuPDF
from PIL import Image
Image.MAX_IMAGE_PIXELS = 933120000

def screenshot_pdfs(folder_path, image_quality=90, crop_ratio=1):
    for filename in os.listdir(folder_path):
        if filename.endswith('.pdf'):
            pdf_path = os.path.join(folder_path, filename)
            doc = fitz.open(pdf_path)

            # Render the first page
            page = doc.load_page(0)  # 0 is the first page
            #pix = page.get_pixmap(matrix=fitz.Matrix(300 / 72, 300 / 72))  # High resolution
            pix = page.get_pixmap(matrix=fitz.Matrix(30 / 72, 30 / 72))  # High resolution

            # Save to an image
            base_name = os.path.splitext(pdf_path)[0]
            img_path = base_name + ".png"
            pix.save(img_path)

            # Open the image and crop
            img = Image.open(img_path)
            width, height = img.size
            img_cropped = img.crop((0, 0, width, height * crop_ratio))

            # Save the cropped image as JPEG with specified quality
            output_path = os.path.splitext(pdf_path)[0] + ".jpg"
            img_cropped.save(output_path, "JPEG", quality=image_quality)

            # Close the PDF document and delete the temporary PNG file
            doc.close()
            os.remove(img_path)
            print(filename.split('.')[0])

# Example usage
screenshot_pdfs('./', image_quality=90, crop_ratio=1.0)
