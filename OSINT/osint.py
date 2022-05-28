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
    parser.add_argument("-p", help="Get some additional information about a phone number")
    parser.add_argument("-a", help="Address")
    parser.add_argument("-ch", help="Use Censys to query for host specific information")
    parser.add_argument("-e", help ="Email")
    
    args = parser.parse_args()

    if args.p:
        phoneVerification(args.p)
    elif args.ch:
        censysHostQuery(args.ch)
    elif args.a:
        addressValidation(args.a)
    elif args.e:
        emailValidation(args.e)
    else: 
        parser.print_help()

def buildLookUp(jsonData):
    lookup = StreetLookup()
    lookup.addressee = jsonData['addressee']
    lookup.street = jsonData['street']
    lookup.street2 = jsonData['street2']
    lookup.secondary = jsonData['secondary']
     # Only applies to Puerto Rico addresses
    lookup.urbanization = jsonData['urbanization'] 
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

def emailValidation(email):
    # TODO: Implement email lookups
    return

def phoneVerification(phoneNumber):
    response = requests.get(VERI_API + phoneNumber + "&key=" + VERI_API_KEY)
    if response.status_code == 200:
        printPhoneReport(response)
    else:
        print(
        '''Error! veriphone's api returned", {status_code}
Please ensure your API key is properly configured on your shell profile 
and that your key is up-to-date.'''.format(status_code=response.status_code))
        exit(1)

def printPhoneReport(response):
    resJson = response.json()
    print("International Number:", resJson['international_number'])
    print("Local Number:", resJson['local_number'])
    print("Region:", resJson['phone_region'])
    print("Country:", resJson['country'])
    print("Country Prefix:", resJson['country_prefix'])
     
if __name__ == "__main__":
    main()