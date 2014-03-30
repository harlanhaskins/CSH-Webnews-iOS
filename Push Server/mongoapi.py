from pymongo import MongoClient
import re

"""
Connects to the Mongo server, the webnewsios database, and the users
collection.

If these do not exist, they are created.
"""
credentials = "" #Credentials withheld.
databaseURI = "mongodb://@db1.csh.rit.edu/webnewspush"
database = MongoClient(databaseURI).webnewspush.users
# database = MongoClient().webnewsios.users
API_KEY_KEY = "apiKey"
DEVICE_TOKEN_KEY = "deviceTokens"
DEVELOPER_KEY = "dev"
UNREAD_POSTS_KEY = "unreadReplies"
DEVICE_TYPE_KEY = "deviceType"
DEVICES_KEY = "devices"
ANDROID_DEVICE_TYPE = 'android'
IOS_DEVICE_TYPE = 'ios'
WINDOWS_PHONE_DEVICE_TYPE = 'windowsphone'
DEVICE_TYPE_KEYS = [ANDROID_DEVICE_TYPE, IOS_DEVICE_TYPE, WINDOWS_PHONE_DEVICE_TYPE]

def insertUser(deviceToken, apiKey, deviceType):
    """
    Inserts a user with a given api key and device token into the database.

    If there is already a user with a given API key, the provided device token
    is appended to their list of tokens. This is so people can have multiple devices
    receiving notifications.

    If there is already a user with the given device token, the provided token is
    removed from their list (or the user is deleted if that was their only token)
    and the token is added to the new user's list.

    Returns: True if the database was updated successfully. False if there was an
    error.
    """
    # If a user with that token exists, remove that token from their
    # list and update that user in the database.
    #
    # If the token does not exist, then nothing happens.
    clearToken(deviceToken)

    # Check if that user with that key already exist in the store.
    newUser = userWithAPIKey(apiKey)
    if not newUser:
        # If they don't, then add a new user with one token.
        return database.insert(newUserDict(deviceToken, apiKey, deviceType))

    # Check to see if that's the same user.
    # No sense in doing anything if the deviceToken and apiKey
    # pair already exist in the store.
    userWithToken = userWithDeviceToken(deviceToken)
    if userWithToken and (userWithToken[API_KEY_KEY] == newUser[API_KEY_KEY]):
        return userWithToken

    # Update the user.
    return addToken(newUser, deviceToken, deviceType)

def apiKeyLookupQuery(apiKey):
    """
    This is a dictionary containing the API key of the user we're looking for.
    Mongo will search the users for anything that contains this key:value pair.
    """
    return {API_KEY_KEY : apiKey}

def deviceTokenLookupQuery(deviceToken):
    """
    This is a dictionary containing the device token of the user we're looking for.
    Mongo will search the users for any user who has this token in their list of
    tokens.
    """
    deviceQueries = []
    for deviceType in DEVICE_TYPE_KEYS:
        deviceQueries.append({DEVICE_TOKEN_KEY + "." + deviceType: deviceToken})

    return {"$or":deviceQueries}

def addToken(user, token, deviceType):
    deviceTokens = user[DEVICE_TOKEN_KEY]
    currentDeviceType = deviceTypeOfToken(user, token)

    if currentDeviceType == deviceType:
        return user
    elif currentDeviceType:
        deviceTokens[currentDeviceType].remove(token)

    if deviceType in deviceTokens:
        deviceTokens[deviceType].append(token)
    else:
        deviceTokens[deviceType] = [token]

    return updateUser(user)

def deviceTypeOfToken(user, deviceToken):
    deviceTokens = user[DEVICE_TOKEN_KEY]
    for deviceType in DEVICE_TYPE_KEYS:
        if deviceType in deviceTokens:
            tokens = deviceTokens[deviceType]
            if tokens:
                if deviceToken in tokens:
                    return deviceType
    return None

def printUsers():
    """
    This prints each user on a new line to standard output.
    """
    for user in database.find():
        print(stringForUser(user))
    print("\n")

def stringForUser(userDictionary):
    """
    Returns a string representation of a user (so far their api key and all tokens)
    """
    string = "\nAPI Key: "
    string += userDictionary[API_KEY_KEY]
    string += "\nTokens: "
    for token in userDictionary[DEVICE_TOKEN_KEY]:
        string += "\n\t"
        string += token
    return string

def clearUsers():
    """
    Warns and then deletes all users in the store. Use with caution!!!
    """
    response = raw_input("Are you sure you want to clear ALL the users? ")
    if boolFromString(response):
        for user in database.find():
            database.remove(user)

def allUsers():
    """
    Returns a list of every user in the database.
    """
    return [user for user in database.find()]

def allDevelopers():
    return [user for user in database.find(developerLookupQuery())]

def developerLookupQuery():
    return {DEVELOPER_KEY : True}

def userWithAPIKey(apiKey):
    """
    Finds a single user in the database that matches a given API Key, using the
    lookup query defined in apiKeyLookupQuery()
    """
    return database.find_one(apiKeyLookupQuery(apiKey))

def userWithDeviceToken(deviceToken):
    """
    Finds a single user in the database that matches a given deviceToken, using
    the lookup query defined in deviceTokenLookupQuery()
    """
    return database.find_one(deviceTokenLookupQuery(deviceToken))

def newUserDict(deviceToken, apiKey, deviceType):
    """
    Returns a Mongo dictionary representation for inserting a new user with a given
    API key and token.
    """
    return {API_KEY_KEY : apiKey,
            DEVELOPER_KEY : False,
            UNREAD_POSTS_KEY : [],
            DEVICE_TOKEN_KEY : {deviceType : [deviceToken]}}

def clearToken(deviceToken):
    """
    Deletes a user with a given device token from the list.

    If the user has multiple device tokens, only the given token will be removed.

    If the user only has one token, then the entire user will be removed.

    If the API key is invalid, then the entire entry is removed from the database.
    """
    user = userWithDeviceToken(deviceToken)
    if (user):
        # Check to see if that token really does exist in the given user.
        deviceTokens = user[DEVICE_TOKEN_KEY]
        for deviceType in DEVICE_TYPE_KEYS:
            if deviceType in deviceTokens:
                tokens = deviceTokens[deviceType]
                if deviceToken in tokens:
                    # If so, remove it from the list and update.
                    tokens.remove(deviceToken)
                    if len(tokens) == 0:
                        deviceTokens.pop(deviceType, None)
                    return updateUser(user)
    return user

def updateUser(user):
    """
    Updates a user in the database. Uses provided user's apiKey and calls the Mongo
    update() function.
    """
    # Grab the API key.
    apiKey = user[API_KEY_KEY]

    # If the provided user does not have a key, don't update anything.
    if not apiKey:
        return None

    # If the user doesn't have any tokens before they get updated in the server,
    # Then just delete the entry. This user is useless.
    deviceTokens = user[DEVICE_TOKEN_KEY]
    containsAtLeastOneType = False

    for deviceType in DEVICE_TYPE_KEYS:
        if deviceType in deviceTokens:
            tokens = deviceTokens[deviceType]

            if tokens: # Will also check len(tokens) > 0
                containsAtLeastOneType = True

    if not containsAtLeastOneType:
        return removeUserWithAPIKey(apiKey)

    # Update the user. We want to look the user up by API key so we know what to update.
    return database.update(apiKeyLookupQuery(apiKey), user)

def removeUserWithAPIKey(apiKey):
    """
    Removes a user with a given API Key from the database.
    """
    userToRemove = userWithAPIKey(apiKey)
    if (userToRemove):
        return database.remove(userToRemove)

def clearPostsForAPIKey(apiKey):
    """
    Removes all of the posts for a user.
    """
    userToClear = userWithAPIKey(apiKey)
    if (userToClear):
        userToClear[UNREAD_POSTS_KEY] = []
        return updateUser(userToClear)

def updatePostIDListForAPIKey(posts, apiKey):
    """
    Finds the user with a given API key and overwrites their unreadPosts list with the list provided.
    """
    user = userWithAPIKey(apiKey)
    if user:
        user[UNREAD_POSTS_KEY] = posts
        updateUser(user)

def postIdentifierList(posts):
    """
    Converts a list of WebNews Post Objects into a list of unique string identifiers for posts.
    """
    # Because I don't care at all about storing the actual post data,
    # I decided to store only the pertinent parts of the post data.
    idList = []
    for thread in posts:
        post = thread['post']
        idList.append(post['newsgroup'] + " - " + str(post['number']))
    return idList


def boolFromString(inputString):
    """
    Returns a boolean representation of a string. It checks for the existence of
    the characters 'y', 'Y', 't', and 'T', and the digits 1-9.

    If any of those exist, True. Otherwise, False.

    The function ignores whitespace.
    """
    return not not re.search("[yYtT1-9]", inputString.strip())
