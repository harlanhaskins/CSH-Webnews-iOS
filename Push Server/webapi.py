#!/usr/bin/env python

from flask import Flask, Response
from flask import request
from flask.json import jsonify
import mongoapi
import argparse
from daemonize import Daemonize

app = Flask(__name__)

@app.route("/token", methods=["POST"])
def token():
    arguments = request.args
    token = arguments.get("token", "")
    apiKey = arguments.get("apiKey", "")
    deviceType = arguments.get("deviceType", "")

    if not (token and deviceType and apiKey):
        return responseWithMessage("You must provide an API Key, a push token, and a device type.", 412)

    if not deviceType in mongoapi.DEVICE_TYPE_KEYS:
        return responseWithMessage("Only 'ios', 'windowsphone', and 'android' are supported as valid device types.", 412)

    success = mongoapi.insertUser(token, apiKey, deviceType)
    if success:
        return successWithMessage('The user was updated successfully.')
    else:
        return responseWithMessage('The database encountered an error inserting the token', 500)

def successWithMessage(message):
    return responseWithMessage(message, 200)

def responseWithMessage(message, code):
    return Response(message, status=code)

if __name__ == "__main__":

    def main():
        parser = argparse.ArgumentParser()
        parser.add_argument("-t", "--test",
                            help="Runs the server in test mode and updates the testUsers database.",
                            action="store_true")

        args = parser.parse_args()

        if args.test:
            mongoapi.database = mongoapi.MongoClient().webnewsios.testUsers

        app.run(host="localhost", debug=args.test)
    main()
    """
    appname = "com.harlanhaskins.webnewspushwebapi"
    pidfile = "/tmp/" + appname + ".pid"

    daemon = daemonize(app=appname, pid=pidfile, action=main)
    daemon.start()
    """
