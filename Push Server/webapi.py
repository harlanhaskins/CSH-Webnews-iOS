#!/usr/bin/env python

from flask import Flask, Response
from flask import request
from flask.json import jsonify
import mongoapi
import argparse

app = Flask(__name__)

@app.route("/token", methods=["POST"])
def token():
    arguments = request.args
    token = arguments.get("token", "")
    apiKey = arguments.get("apiKey", "")
    deviceType = arguments.get("deviceType", "")

    if not (token and deviceType and apiKey):
        return errorWithMessage("You must provide both an API Key, a push token, and a device type.")

    if not deviceType in mongoapi.DEVICE_TYPE_KEYS:
        return errorWithMessage("Only 'ios' and 'android' are supported as valid device types.")

    success = mongoapi.insertUser(token, apiKey, deviceType)
    if success:
        return successWithMessage('The user was updated successfully.')
    else:
        return errorWithMessage('The database encountered an error inserting the token')

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
