#!/usr/bin/env python

from flask import Flask, Response
from flask import request
from bson import Binary, Code
from bson.json_util import dumps
import api

app = Flask(__name__)

@app.route("/token", methods=["GET", "POST"])
def token():
    arguments = request.args
    token = arguments.get("token", "")
    apiKey = arguments.get("apiKey", "")

    if (not token or not apiKey):
        return errorWithMessage("You must provide both an\
                API Key and a push token.")

    success = api.insertUser(token, apiKey)
    if success:
        return successWithMessage('The user was updated successfully.')
    else:
        return errorWithMessage('The database encountered an error \
                inserting the token')

@app.route("/user", methods=["GET", "POST"])
def user():
    arguments = request.args
    apiKey = arguments.get("apiKey", "")
    user = api.userWithAPIKey(apiKey)
    if user:
        return successWithMessage(user)
    else:
        return errorWithMessage('Could not find user with that API Key.')

def successWithMessage(message):
    return responseTemplateWithKeyValue('S', message)

def errorWithMessage(message):
    return responseTemplateWithKeyValue('E', message)

def responseTemplateWithKeyValue(key, value):
    return Response('{' + dumps(key) + ' : ' + dumps(value) + '}', \
            mimetype="application/json")

if __name__ == "__main__":
    app.run(debug=True)
