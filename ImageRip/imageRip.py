import string
from tokenize import String
from unittest import result
from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS
from GPSPhoto import gpsphoto
import exifread
import sys
import argparse
import json

def main():

	parser = argparse.ArgumentParser(description='Extract EXIF data from an image')
	parser.add_argument('imageName', help='Path to an image')
	parser.add_argument('-o', help='Output path for resulting JSON')
	args = parser.parse_args()

	imageName = args.imageName

	try:
		image = Image.open(imageName)
	except FileNotFoundError:
		print(imageName + ' could not be opened. Please specify a valid image path.')
		return 

	exifData = image._getexif()

	result = {}

	for tagId in exifData:
		tag = TAGS.get(tagId, tagId)
		data = exifData.get(tagId)
		if isinstance(data, bytes):
			try:
				data = data.decode()
			except UnicodeError:
				data = data.decode('latin-1')	
		result[tag] = str(data)

	gpsData = gpsphoto.getGPSData(imageName)
	result['Latitude'] = gpsData['Latitude']
	result['Longitude'] = gpsData['Longitude']
	link = 'https://www.google.com/maps/place/%s,%s' % (gpsData['Latitude'], gpsData['Longitude'])
	result['Google-Maps-Link'] = link
	
	finalJSON = json.dumps(result, indent=4)

	if args.o:
		fp = open(args.o, 'w') 
		fp.write(finalJSON)
	else:
		print(finalJSON)
		
	

if __name__ == "__main__":
    main()