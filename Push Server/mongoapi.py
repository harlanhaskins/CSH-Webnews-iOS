from pymongo import MongoClient
import re

"""
Connects to the Mongo server, the webnewsios database, and the users
collection.

If these do not exist, they are created.
"""
database = MongoClient().webnewsios.users
API_KEY_KEY = "apiKey"
DEVICE_TOKEN_KEY = "deviceToken"

def insertUser(deviceToken, apiKey):
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
    userWithToken = userWithDeviceToken(deviceToken)
    if userWithToken:
        # If a user with that token exists, remove that token from their
        # list and update that user in the database.
        clearToken(deviceToken, userWithToken)

    newUser = userWithAPIKey(apiKey)
    if not newUser:
        return database.insert(newUserDict(deviceToken, apiKey))

    userTokens = newUser[DEVICE_TOKEN_KEY]
    userTokens.append(deviceToken)

    return updateUser(newUser)

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
    return {DEVICE_TOKEN_KEY : {"$in" : [deviceToken]}}

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

def newUserDict(deviceToken, apiKey):
    """
    Returns a Mongo dictionary representation for inserting a new user with a given
    API key and token.
    """
    return {API_KEY_KEY : apiKey,
            DEVICE_TOKEN_KEY : [deviceToken]}

def userExistenceQuery(deviceToken):
    """
    Returns a javascript query that can be put into the Mongo where() function to
    select a user WHERE the condition is true.
    """
    return DEVICE_TOKEN_KEY + " === " + deviceToken

def clearToken(deviceToken, user):
    """
    Deletes a user with a given API key and device token from the list.

    If the user has multiple device tokens, only the given token will be removed.

    If the user only has one token, then the entire user will be removed.

    If the API key is invalid, then the entire entry is removed from the database.
    """
    if (user):

        tokens = user[DEVICE_TOKEN_KEY]
        if deviceToken in tokens:
            tokens.remove(deviceToken)

        return updateUser(user)

def updateUser(user):
    """
    Updates a user in the database. Uses provided user's apiKey and calls the Mongo
    update() function.
    """
    apiKey = user[API_KEY_KEY]

    if not apiKey:
        return False

    tokens = user[DEVICE_TOKEN_KEY]
    if len(tokens) == 0:
        return database.remove(userWithAPIKey(apiKey))

    return database.update(apiKeyLookupQuery(apiKey), user)

def removeUserWithAPIKey(apiKey):
    """
    Removes a user with a given API Key from the database.
    """
    userToRemove = userWithAPIKey(apiKey)
    if (userToRemove):
        database.remove(userToRemove)

def boolFromString(inputString):
    """
    Returns a boolean representation of a string. It checks for the existence of
    the characters 'y', 'Y', 't', and 'T', and the digits 1-9.

    If any of those exist, True. Otherwise, False.

    The function ignores whitespace.
    """
    return not not re.search("[yYtT1-9]", inputString.strip())
