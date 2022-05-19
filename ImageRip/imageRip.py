from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS
from GPSPhoto import gpsphoto
import exifread
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

	gpsData = gpsphoto.getGPSData(imageName)
	print(f"{'Latitude':25}: {gpsData['Latitude']}")
	print(f"{'Longitude':25}: {gpsData['Longitude']}")
	link = 'https://www.google.com/maps/place/%s,%s' % (gpsData['Latitude'], gpsData['Longitude'])
	print(f"{'Google Maps Link:25':25}: {link}")

if __name__ == "__main__":
    main()