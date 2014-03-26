#!/usr/bin/env python

import mongoapi
import requests
import bson
from bson.json_utils import dumps

baseURL = "https://webnews.csh.rit.edu/"

def unreadCount(apiKey):
    url = baseURL + "unread_counts?" + credentials(apiKey)
    request = requests.get(url)
    if ("does not match any known user" in request.text):
        return None
    else:
        return request.json()

def credentials(apiKey):
    return "api_key=" + apiKey + "&api_agent=iOSPushServer"
