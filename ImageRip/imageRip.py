from PIL import Image
from PIL.ExifTags import TAGS
import sys

def main():

	if len(sys.argv) != 2:
		print("""Usage: python3 imageRip.py <Image File Name>""")
		return

	imageName = sys.argv[1]
	try:
		image = Image.open(imageName)
	except FileNotFoundError:
		print(imageName + ' could not be opened. Please specify a valid image path.')
		return 

	print(image)
	exifData = image._getexif()

	for tagId in exifData:

		tag = TAGS.get(tagId, tagId)
		data = exifData.get(tagId)

		if isinstance(data, bytes):
			try:
				data = data.decode()
			except UnicodeError:
				data = data.decode('latin-1')

		print(f"{tag:25}: {data}")

main()