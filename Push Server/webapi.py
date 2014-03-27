#!/usr/bin/env python

from flask import Flask, Response
from flask import request
from flask.json import jsonify
import mongoapi
import argparse

app = Flask(__name__)

@app.route("/token", methods=["GET", "POST"])
def token():
    arguments = request.args
    token = arguments.get("token", "")
    apiKey = arguments.get("apiKey", "")

    if (not token or not apiKey):
        return errorWithMessage("You must provide both an API Key and a push token.")

    success = mongoapi.insertUser(token, apiKey)
    if success:
        return successWithMessage('The user was updated successfully.')
    else:
        return errorWithMessage('The database encountered an error inserting the token')

@app.route("/user", methods=["GET", "POST"])
def user():
    arguments = request.args
    apiKey = arguments.get("apiKey", "")
    user = mongoapi.userWithAPIKey(apiKey)
    if user:
        return successWithMessage(user)
    else:
        return errorWithMessage('Could not find user with that API Key.')

def successWithMessage(message):
    return jsonify(S=message)

def errorWithMessage(message):
    return jsonify(E=message)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--test",
                        help="Runs the server in test mode and updates the testUsers database.",
                        action="store_true")

    args = parser.parse_args()

    if args.test:
        mongoapi.database = mongoapi.MongoClient().webnewsios.testUsers

    app.run(debug=args.test)
