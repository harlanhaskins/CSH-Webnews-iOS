#!/usr/bin/env python

import mongoapi
import requests
import pushnotifications
import argparse

baseURL = "https://webnews.csh.rit.edu/"

def unreadCount(apiKey):
    url = baseURL + "search?" + credentials(apiKey) + "&unread=true&personal_class=mine_reply&limit=20"
    request = requests.get(url, headers = {'Accept': 'application/json'})
    if ("does not match any known user" in request.text):
        return None
    else:
        return request.json()

def credentials(apiKey):
    return "api_key=" + apiKey + "&api_agent=iOSPushServer"

def checkAllUsers(debug):
    for user in mongoapi.allUsers():
        apiKey = user[mongoapi.API_KEY_KEY]
        tokens = user[mongoapi.DEVICE_TOKEN_KEY]
        isDev = user[mongoapi.DEVELOPER_KEY]

        unreadPosts = unreadCount(apiKey)
        if not unreadPosts:
            # If the user's API key is invalid, then remove the user from the database.
            mongoapi.removeUserWithAPIKey(apiKey)
            continue

        unreadPostCount = len(unreadPosts['posts_older'])
        if unreadPostCount > 0 or (debug and isDev):
            pushnotifications.sendUnreadReplyAlert(unreadPostCount, tokens)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--test",
                        help="Send notifications even when replies are zero.",
                        action="store_true")
    args = parser.parse_args()

    checkAllUsers(args.test)
