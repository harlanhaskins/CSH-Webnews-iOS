#!/usr/bin/env python

import api
import requests

baseURL = "https://webnews.csh.rit.edu/"

def unreadCount(apiKey):
    url = baseURL + "unread_counts?" + credentials(apiKey)
    request = requests.get(url)
    print(request.text)
    return None if ("does not match any known user" in request.text) \
            else request.json()

def credentials(apiKey):
    return "api_key=" + apiKey + "&api_agent=iOSPushServer"

print(unreadCount("365115abd911fe30"))
