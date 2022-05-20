import string
from tokenize import String
from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS
from GPSPhoto import gpsphoto
import exifread
import sys
import argparse

def main():

	parser = argparse.ArgumentParser(description='Extract EXIF data from an image')
	parser.add_argument('imageName', help='Path to an image')
	args = parser.parse_args()
	print(args)

	imageName = args.imageName

	try:
		image = Image.open(imageName)
	except FileNotFoundError:
		print(imageName + ' could not be opened. Please specify a valid image path.')
		return 

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

	gpsData = gpsphoto.getGPSData(imageName)
	print(f"{'Latitude':25}: {gpsData['Latitude']}")
	print(f"{'Longitude':25}: {gpsData['Longitude']}")
	link = 'https://www.google.com/maps/place/%s,%s' % (gpsData['Latitude'], gpsData['Longitude'])
	print(f"{'Google Maps Link:':25}: {link}")

if __name__ == "__main__":
    main()