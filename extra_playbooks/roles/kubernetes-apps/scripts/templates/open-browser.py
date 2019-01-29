#!/usr/bin/env python

import os, webbrowser, sys

try:
    from urllib import pathname2url
except:
    from urllib.request import pathname2url

URL = sys.argv[1]

FINAL_ADDRESS = "{}".format(URL)

print("FINAL_ADDRESS: {}".format(FINAL_ADDRESS))

# MacOS
chrome_path = "open -a /Applications/Google\ Chrome.app %s"

webbrowser.get(chrome_path).open(FINAL_ADDRESS)
