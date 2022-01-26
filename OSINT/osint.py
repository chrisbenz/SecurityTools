import sys
import os
import requests

VERI_API_KEY = os.environ['VERI_API_KEY']
VERI_API = "https://api.veriphone.io/v2/verify?phone=" 

def main():
    args = sys.argv
    opt = sys.argv[1]
    pn = sys.argv[2]

    print(VERI_API + pn + "&key=" + VERI_API_KEY)
    response = requests.get(VERI_API + pn + "&key=" + VERI_API_KEY)

    print(response)

if __name__ == "__main__":
    main()