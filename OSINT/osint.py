import argparse
from ast import arg, parse
from cgitb import lookup
import json
import pprint
import requests
import os
from tokenize import String

from smartystreets_python_sdk import StaticCredentials, exceptions, ClientBuilder
from smartystreets_python_sdk.us_street import Lookup as StreetLookup
from censys.search import CensysHosts

# Setup tokens, API keys, auth IDs, etc.
VERI_API_KEY = os.environ['VERI_API_KEY']
SMARTY_AUTH_ID = os.environ['SMARTY_AUTH_ID']
SMARTY_TOKEN = os.environ['SMARTY_TOKEN']

VERI_API = "https://api.veriphone.io/v2/verify?phone=" 

creds = StaticCredentials(SMARTY_AUTH_ID, SMARTY_TOKEN)

def main():

    parser = argparse.ArgumentParser(description="Simple script for querying a few different OSINT APIS")
    parser.add_argument("-p", help="Phone number")
    parser.add_argument("-a", default="address.json", help="Address", const="address.json", nargs='?')
    parser.add_argument("-ch", help="Host")
    args = parser.parse_args()

    if args.p:
        response = requests.get(VERI_API + args.p + "&key=" + VERI_API_KEY)
        if response.status_code == 200:
            print_report(response)
    elif args.ch:
        censysHostQuery(args.ch)
    elif args.a:
        addressValidation(args.a)

def print_report(response):
    resJson = response.json()
    print("International Number:", resJson['international_number'])
    print("Local Number:", resJson['local_number'])
    print("Region:", resJson['phone_region'])
    print("Country:", resJson['country'])
    print("Country Prefix:", resJson['country_prefix'])

def buildLookUp(jsonData):
    lookup = StreetLookup()
    lookup.addressee = jsonData['addressee']
    lookup.street = jsonData['street']
    lookup.street2 = jsonData['street2']
    lookup.secondary = jsonData['secondary']

     # Only applies to Puerto Rico addresses
    lookup.urbanization = "" 

    lookup.city = jsonData['city']
    lookup.state = jsonData['state']
    lookup.zipcode = jsonData['zipcode']
    lookup.candidates = jsonData['candidates']
    lookup.match = jsonData['match'] 
    return lookup

def addressValidation(fileName: String):
    f = open(fileName)
    data = json.load(f)
    client = ClientBuilder(creds).with_licenses(["us-core-cloud"]).build_us_street_api_client()

    lookup = buildLookUp(data)

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

def censysHostQuery(host):
    h = CensysHosts()
    res = h.view(host)
    pp = pprint.PrettyPrinter(indent=2)
    pp.pprint(res)
     
if __name__ == "__main__":
    main()