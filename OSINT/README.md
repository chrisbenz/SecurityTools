# OSINT Script
A basic Python script for querying a few interesting
OSINT APIs

## Requirements
- Smarty Python SDK
```
pip install smartystreets_python_sdk
```
- API Keys

As shown in the script, it is recommended to 
save your API keys into environment variables in your shell profile.
```
VERI_API_KEY = os.environ['VERI_API_KEY']
SMARTY_AUTH_ID = os.environ['SMARTY_AUTH_ID']
SMARTY_TOKEN = os.environ['SMARTY_TOKEN']
```