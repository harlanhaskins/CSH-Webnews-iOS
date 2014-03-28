#!/usr/bin/env python
from __future__ import print_function
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

def checkAllUsers(debug, verbose):
    for user in mongoapi.allUsers():
        apiKey = user[mongoapi.API_KEY_KEY]
        tokens = user[mongoapi.DEVICE_TOKEN_KEY]
        isDev = user[mongoapi.DEVELOPER_KEY]
        posts = user[mongoapi.UNREAD_POSTS_KEY]
        if verbose: print("Processing user: " + apiKey)

        unreadPosts = unreadCount(apiKey)
        if not unreadPosts:
            # If the user's API key is invalid, then remove the user from the database.
            mongoapi.removeUserWithAPIKey(apiKey)
            if verbose: print("\tRemoving API Key: " + apiKey)
            continue

        olderPosts = unreadPosts['posts_older']
        if olderPosts == None:
            if verbose: print("\tNo older posts returned.")
            continue

        unreadPostCount = len(differenceOfLists(olderPosts, posts))
        if verbose: print("\tUser has " + str(unreadPostCount) + " unread posts.")
        if unreadPostCount > 0 or (debug and isDev):
            if verbose: print("\tSending notification...", end="")
            pushnotifications.sendUnreadReplyAlert(unreadPostCount, tokens)
            if verbose: print("Done.")

        if verbose: print("\tUpdating posts.\n\t\tOld count: " + \
                          str(len(posts)) + \
                          "\n\t\tNew count: " + str(len(olderPosts)))
        mongoapi.updatePostsForAPIKey(olderPosts, apiKey)

def differenceOfLists(list1, list2):
    s = set(list2)
    return [x for x in list1 if x not in s]

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--test",
                        help="Send notifications even when replies are zero.",
                        action="store_true")
    parser.add_argument("-v", "--verbose",
                        help="Prints information about each user.",
                        action="store_true")
    args = parser.parse_args()

    checkAllUsers(debug=args.test, verbose=args.verbose)
