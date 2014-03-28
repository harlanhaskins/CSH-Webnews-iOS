#!/usr/bin/env python
from __future__ import print_function
import mongoapi
import requests
import pushnotifications
import argparse

baseURL = "https://webnews.csh.rit.edu/"

def unreadReplies(apiKey):
    hasOlder = True
    replies = []
    url = baseURL + "search?" + credentials(apiKey) + "&unread=true&personal_class=mine_reply&limit=20"

    from_older = ""

    while hasOlder:
        request = requests.get(url + from_older, headers = {'Accept': 'application/json'})
        if ("does not match any known user" in request.text):
            return None

        threads = request.json()
        posts = threads['posts_older']
        hasOlder = threads['more_older']
        if posts:
            replies += posts
            oldestPost = posts[-1]['post']
            from_older = "&from_older=" + oldestPost['date']

    return mongoapi.postIdentifierList(replies)

def credentials(apiKey):
    return "api_key=" + apiKey + "&api_agent=iOSPushServer"

def checkAllUsers(debug, verbose):
    for user in mongoapi.allUsers():
        apiKey = user[mongoapi.API_KEY_KEY]
        tokens = user[mongoapi.DEVICE_TOKEN_KEY]
        isDev = user[mongoapi.DEVELOPER_KEY]
        posts = user[mongoapi.UNREAD_POSTS_KEY]

        if verbose: print("Processing user: " + apiKey)
        apiShortKey = apiKey[:4] + ": "

        newPosts = unreadReplies(apiKey)
        if newPosts == None:
            # If the user's API key is invalid, then remove the user from the database.
            mongoapi.removeUserWithAPIKey(apiKey)
            if verbose: print("\t" + apiShortKey + "Removing API Key: " + apiKey)
            continue

        if verbose: print("\t" + apiShortKey + "New Posts: " + str(newPosts))

        unreadPostCount = len(differenceOfLists(newPosts, posts))
        if verbose: print("\t" + apiShortKey + "User has " + str(unreadPostCount) + " unread posts.")
        if unreadPostCount > 0 or (debug and isDev):
            if verbose: print("\t" + apiShortKey + "Sending notification...", end="")
            pushnotifications.sendUnreadReplyAlert(unreadPostCount, tokens)
            if verbose: print("Done.")
        else:
            if verbose: print("\t" + apiShortKey + "Not sending notification.")

        if newPosts == posts:
            if verbose: print("\t" + apiShortKey + "Not updating posts.")
        else:
            if verbose: print("\t" + apiShortKey + "Updating posts.\n\t\tOld count: " + \
                              str(len(posts)) + \
                              "\n\t\tNew count: " + str(len(newPosts)))
            mongoapi.updatePostIDListForAPIKey(newPosts, apiKey)

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
