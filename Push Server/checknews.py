#!/usr/bin/env python
from __future__ import print_function
import mongoapi
import requests
import pushnotifications
import argparse
import time
from multiprocessing import Pool

baseURL = "https://webnews.csh.rit.edu/"
verbose = False
debug = False

def unreadReplies(apiKey):
    """
    For a given API key, the function finds all direct replies that are unread.

    Returns: A list of strings like this: "newsgroup - number", of every unread post.
    """
    hasOlder = True
    replies = []
    url = baseURL + "search?" + credentials(apiKey) + "&unread=true&personal_class=mine_reply&limit=20"

    from_older = ""

    apiShortKey = shortAPIKey(apiKey)
    requestAttempt = 0

    while hasOlder:
        requestAttempt += 1
        if verbose: print("\t" + apiShortKey + "Requesting posts - attempt " + str(requestAttempt))
        request = requests.get(url + from_older, headers = {'Accept': 'application/json'}, verify=False)
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
    """
    Returns the WebNews API credential parameters for a given API key.
    """
    return "api_key=" + apiKey + "&api_agent=Mobile%20Push%20Server"

def shortAPIKey(apiKey):
    """
    Returns a shortened version of an API key, along with a colon and a space.
    """
    return apiKey[:4] + ": "

def checkAllUsers(threaded=False):
    """
    Iterates through every user in the Mongo database checking for their unread
    posts, and sending push notifications when necessary.

    If the API key of a certain user is reported invalid by WebNews, that entire user is removed from the database.

    The function checks the unread posts returned through unreadReplies() and compares it to the posts in the database.
    If any posts exist in the returned data that don't exist in the database already, those posts are considered new to the
    push API, and will be sent as a new notification.

    Once the new posts have been determined, the posts in the database are overwritten with the posts returned from unreadReplies().
    """
    if verbose: print("----- New Run ----")
    if threaded:
        pool = Pool(60)
        results = [pool.apply_async(processUnreadRepliesForUser, args=(user,)) for user in mongoapi.allUsers()]
        runResults = [result.get() for result in results]
    else:
        for user in mongoapi.allUsers():
            processUnreadRepliesForUser(user)


def processUnreadRepliesForUser(user):
    apiKey = user[mongoapi.API_KEY_KEY]
    tokens = user[mongoapi.DEVICE_TOKEN_KEY]
    isDev = user[mongoapi.DEVELOPER_KEY]
    posts = user[mongoapi.UNREAD_POSTS_KEY]

    if verbose: print("Processing user: " + apiKey)

    apiShortKey = shortAPIKey(apiKey)

    newPosts = unreadReplies(apiKey)
    if newPosts == None:
        # If the user's API key is invalid, then remove the user from the database.
        mongoapi.removeUserWithAPIKey(apiKey)
        if verbose: print("\t" + apiShortKey + "Removing API Key: " + apiKey)
        return

    if verbose: print("\t" + apiShortKey + "New Posts: " + str(newPosts))

    unreadPostCount = len(differenceOfLists(newPosts, posts))
    if verbose:
        postsWord = "post" if unreadPostCount == 1 else "posts"
        print("\t" + apiShortKey + "User has " + str(unreadPostCount) + " new unread " + postsWord + ".")
    if unreadPostCount > 0 or (debug and isDev):
        if verbose: print("\t" + apiShortKey + "Sending notification...")
        pushnotifications.sendUnreadReplyAlert(tokens, unreadPostCount, len(newPosts))
        if verbose: print("\t\tDone.")
    else:
        if verbose: print("\t" + apiShortKey + "Not sending notification.")

    numberOfNewPosts = len(newPosts)
    numberOfOldPosts = len(posts)
    if numberOfNewPosts == numberOfOldPosts:
        if verbose: print("\t" + apiShortKey + "Not updating posts.")
    else:
        if numberOfNewPosts < posts:
            pushnotifications.sendSilentBadgeUpdateAlert(tokens, unreadPostCount, len(newPosts))
        if verbose: print("\t" + apiShortKey + "Updating posts.\n\t\tOld count: " + \
                          str(len(posts)) + \
                          "\n\t\tNew count: " + str(len(newPosts)))

        mongoapi.updatePostIDListForAPIKey(newPosts, apiKey)

def differenceOfLists(list1, list2):
    """
    Returns a list of all of the objects in the first list passed in that don't exist in the second list.
    """
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
    parser.add_argument("-f", "--force-repeat",
                        help="Forces the script to keep going even if it's in test mode.",
                        action="store_true")
    parser.add_argument("-s", "--sleep",
                        help="Specifies the duration (in seconds) that the program sleeps between executions.",
                        type=float)
    parser.add_argument("-c", "--cron",
                        help="Run the script in 'cron-mode' meaning that it doesn't repeat ever.",
                        action="store_true")
    parser.add_argument("-p", "--pooled",
                        help="Runs the script multithreaded",
                        action="store_true")
    args = parser.parse_args()

    cron = args.cron
    verbose = args.verbose
    debug = args.test
    threaded = args.pooled
    pushnotifications.verbose = verbose
    forcerepeat = args.force_repeat

    timeout = args.sleep if args.sleep else 10

    while True:
        checkAllUsers(threaded=threaded)
        if (cron or debug) and not forcerepeat:
            break
        time.sleep(timeout)
