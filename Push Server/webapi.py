#!/usr/bin/env python

from flask import Flask
from flask import request
import api

app = Flask(__name__)

@app.route("/token", methods=["GET", "POST"])
def token():
    arguments = request.args
    token = arguments.get("token", "")
    apiKey = arguments.get("apiKey", "")

    if (not token or not apiKey):
        return '{"E" : "You must provide both an API Key and a push token."}'

    success = api.insertUser(token, apiKey)
    if success:
        return '{"S" : "The user was updated successfully."}'
    else:
        return '{"E" : "The database encountered an error inserting the token"}'

if __name__ == "__main__":
    app.run(debug=True)
