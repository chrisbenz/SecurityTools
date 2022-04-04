import argparse
from ast import parse
from cgitb import lookup
import json

import requests
import os
from tokenize import String

from smartystreets_python_sdk import StaticCredentials, exceptions, ClientBuilder
from smartystreets_python_sdk.us_street import Lookup as StreetLookup

# Setup tokens, API keys, auth IDs, etc.
VERI_API_KEY = os.environ['VERI_API_KEY']
SMARTY_AUTH_ID = os.environ['SMARTY_AUTH_ID']
SMARTY_TOKEN = os.environ['SMARTY_TOKEN']

VERI_API = "https://api.veriphone.io/v2/verify?phone=" 

creds = StaticCredentials(SMARTY_AUTH_ID, SMARTY_TOKEN)

def main():

    parser = argparse.ArgumentParser(description="Simple script for querying a few different OSINT APIS")
    parser.add_argument("-p", help="Phone number")
    parser.add_argument("-a", help="Address")
    args = parser.parse_args()

    if args.p:
        response = requests.get(VERI_API + args.p + "&key=" + VERI_API_KEY)
        if response.status_code == 200:
            print_report(response)
    elif args.a:
        addressValidation(args.a)

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
    print("Usage: python3 osint.py -z {zipCodeInfo}")

def addressValidation(fileName: String):
    print(fileName)
    f = open(fileName)
    data = json.load(f)
    print(data)
    print(data['addressee'])

    client = ClientBuilder(creds).with_licenses(["us-core-cloud"]).build_us_street_api_client()

    lookup = StreetLookup()
    lookup.addressee = data['addressee']
    lookup.street = data['street']
    lookup.street2 = data['street2']
    lookup.secondary = data['secondary']

     # Only applies to Puerto Rico addresses
    lookup.urbanization = "" 

    lookup.city = data['city']
    lookup.state = data['state']
    lookup.zipcode = data['zipcode']
    lookup.candidates = data['candidates']
    lookup.match = data['match'] 

    try:
        client.send_lookup(lookup)
    except exceptions.SmartyException as err:
        print(err)
        return

    result = lookup.result

    if not result:
        print("No candidates. This means the address is not valid.")
        return

    first_candidate = result[0]

    print("There is at least one candidate.")
    print("If the match parameter is set to STRICT, the address is valid.")
    print("Otherwise, check the Analysis output fields to see if the address is valid.\n")
    print("ZIP Code: " + first_candidate.components.zipcode)
    print("County: " + first_candidate.metadata.county_name)
    print("Latitude: {}".format(first_candidate.metadata.latitude))
    print("Longitude: {}".format(first_candidate.metadata.longitude))

    f.close()

   
if __name__ == "__main__":
    main()