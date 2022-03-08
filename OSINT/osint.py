import sys
import os
import requests

VERI_API_KEY = os.environ['VERI_API_KEY']
VERI_API = "https://api.veriphone.io/v2/verify?phone=" 

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 osint.py -p <phone number>")

    args = sys.argv
    opt = sys.argv[1]
    pn = sys.argv[2]

    if opt == "-p":
        response = requests.get(VERI_API + pn + "&key=" + VERI_API_KEY)
        if response.status_code == 200:
            resJson = response.json()
            print("International Number:", resJson['international_number'])
            print("Local Number:", resJson['local_number'])
            print("Region:", resJson['phone_region'])
            print("Country:", resJson['country'])
            print("Country Prefix:", resJson['country_prefix'])

if __name__ == "__main__":
    main()