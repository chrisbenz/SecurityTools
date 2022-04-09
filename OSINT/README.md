# OSINT Script
A basic Python script for querying a few interesting
OSINT APIs

## Requirements
- Smarty Python SDK
- Censys
```
pip3 install -r requirements.txt
```
- API Keys

As shown in the script, it is recommended to 
save your API keys into environment variables in your shell profile.
```
VERI_API_KEY = os.environ['VERI_API_KEY']
SMARTY_AUTH_ID = os.environ['SMARTY_AUTH_ID']
SMARTY_TOKEN = os.environ['SMARTY_TOKEN']
```
For Censys, run the following configuration command to configure your `API ID` and `API secret`
```
censys config
```