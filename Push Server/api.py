#!/usr/bin/env python

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

"""
Inserts a user with a given api key and device token into the database.

If there is already a user with a given API key, the provided device token
is appended to their list of tokens. This is so people can have multiple devices
receiving notifications.
"""
def insertUser(deviceToken, apiKey):
    newUser = userWithAPIKey(apiKey)
    if not newUser:
        database.insert(newUserDict(deviceToken, apiKey))
        return

    userTokens = newUser[DEVICE_TOKEN_KEY]
    userTokens.append(deviceToken)

    updateUser(newUser)

"""
This is a dictionary containing the API key of the user we're looking for.
Mongo will search the users for anything that contains this key:value pair.
"""
def apiKeyLookupQuery(apiKey):
    return {API_KEY_KEY : apiKey}

"""
This prints each user on a new line to standard output.
"""
def printUsers():
    for user in database.find():
        print(stringForUser(user))

"""
Returns a string representation of a user (so far their api key and all tokens)
"""
def stringForUser(userDictionary):
    string = "\nAPI Key: "
    string += userDictionary[API_KEY_KEY]
    string += "\nTokens: "
    for token in userDictionary[DEVICE_TOKEN_KEY]:
        string += "\n\t"
        string += token
    return string

"""
Warns and then deletes all users in the store. Use with caution!!!
"""
def clearUsers():
    response = raw_input("Are you sure you want to clear ALL the users? ")
    if boolFromString(response):
        for user in database.find():
            database.remove(user)

"""
Returns a list of every user in the database.
"""
def allUsers():
    return [user for user in database.find()]

"""
Finds a single user in the database that matches a given API Key, using the
lookup query defined in apiKeyLookupQuery()
"""
def userWithAPIKey(apiKey):
    return database.find_one(apiKeyLookupQuery(apiKey))

"""
Returns a Mongo dictionary representation for inserting a new user with a given
API key and token.
"""
def newUserDict(deviceToken, apiKey):
    return {API_KEY_KEY : apiKey,
            DEVICE_TOKEN_KEY : [deviceToken]}

"""
Returns a javascript query that can be put into the Mongo where() function to
select a user WHERE the condition is true.
"""
def userExistenceQuery(deviceToken):
    return DEVICE_TOKEN_KEY + " === " + deviceToken

"""
Deletes a user with a given API key and device token from the list.

If the user has multiple device tokens, only the given token will be removed.

If the user only has one token, then the entire user will be removed.

If the API key is invalid, then the entire entry is removed from the database.
"""
def clearToken(deviceToken, apiKey):
    userToRemove = userWithAPIKey(apiKey)
    if (userToRemove):
        tokens = userToRemove[DEVICE_TOKEN_KEY]
        if len(tokens) == 1:
            database.remove(userToRemove)
        elif deviceToken in tokens:
            tokens.remove(deviceToken)

"""
Updates a user in the database. Uses provided user's apiKey and calls the Mongo
update() function.
"""
def updateUser(user):
    apiKey = user[API_KEY_KEY]

    if not apiKey:
        return

    database.update(apiKeyLookupQuery(apiKey), user)

"""
Removes a user with a given API Key from the database.
"""
def removeUserWithAPIKey(apiKey):
    userToRemove = userWithAPIKey(apiKey)
    if (userToRemove):
        database.remove(userToRemove)

"""
Returns a boolean representation of a string. It checks for the existence of
the characters 'y', 'Y', 't', and 'T', and the digits 1-9.

If any of those exist, True. Otherwise, False.

The function ignores whitespace.
"""
def boolFromString(inputString):
    return not not re.search("[yYtT1-9]", inputString.strip())

    # values = ['y', 't', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    # return any([(x in values) for x in inputString])
