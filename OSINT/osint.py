import sys
import os
import requests

# Setup tokens, API keys, auth IDs, etc.
VERI_API_KEY = os.environ['VERI_API_KEY']
VERI_API = "https://api.veriphone.io/v2/verify?phone=" 

SMARTY_AUTH_ID = os.environ['SMARTY_AUTH_ID']
SMARTY_TOKEN = os.environ['SMARTY_TOKEN']

def main():
    if len(sys.argv) != 3:
        usage_help()
        exit(1)

    args = sys.argv
    opt = sys.argv[1]
    pn = sys.argv[2]

    if opt == "-p":
        response = requests.get(VERI_API + pn + "&key=" + VERI_API_KEY)
        if response.status_code == 200:
            print_report(response)
    elif opt == '-a':
        # TODO: Add Smarty implementation

def print_report(response):
    resJson = response.json()
    print("International Number:", resJson['international_number'])
    print("Local Number:", resJson['local_number'])
    print("Region:", resJson['phone_region'])
    print("Country:", resJson['country'])
    print("Country Prefix:", resJson['country_prefix'])

def usage_help():
    print("Usage: python3 osint.py -p <phone number>")
    print("Usage: python3 osint.py -u <userName>")
    print("Usage: python3 osint.py -a {addressInfo}")

if __name__ == "__main__":
    main()