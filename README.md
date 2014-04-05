# CSH News

An iOS app for Computer Science House's internal WebNews program.

# Building

## iOS App

To build the project yourself, clone the project and then install the pods:

    ~> git clone https://github.com/harlanhaskins/CSH-Webnews-iOS.git
    ~> cd App/CSH-Webnews-iOS
    ~> pod install

Then just build the `CSH News.xcworkspace` file with Xcode.

## Push Server

The push server makes use of a lost of third-party technology. It uses a MongoDB store to keep track of API keys,
device tokens, and unread posts.

You'll need [apns-client](https://pypi.python.org/pypi/apns-client/0.1.8), [Flask](http://flask.pocoo.org),
[PyMongo](http://api.mongodb.org/python/current/), and [Requests](http://docs.python-requests.org/en/latest/).

You can install all of these with this command:

```bash
~> pip install apns-client flask pymongo requests
```

You'll also need to have MongoDB installed. You can install it using the package manager included in your operating
sytem. It's available on [Homebrew](http://brew.sh) as well.


### Web API
Once you've set all that up, you'll need to register the web API for accepting new tokens.

Just run `./webapi.py` and you'll have an instance of the web API at `localhost:5000`.

The Web API returns 

    "The user was added successfully."

or one of these (with a 401 Preciondition Failed status code):

    "You must provide both a token and an API key."
    "Only 'ios', 'android', and 'windowsphone' are supported device types."
    
or this (with a 500 Internal Server Error status code)

    "The server had a problem processing your request."


#### POST /token

`token` accepts only two parameters, and they are both required.

| Parameter      |                   Description                     |
|----------------|---------------------------------------------------|
| `apiKey`       |The API key of the user you're adding a token to.  |
| `token`        |The token to be added to the user's list of tokens.|
| `deviceType`   |The token to be added to the user's list of tokens.|

### WebNews Check Script

This will iterate through all of the users in the database and query their unread posts.

You only need to run this with `./checknews.py`

Please note that if a device token is declared invalid by Apple, it will be removed from the list without warning.
Also note that if an API Key is declared invalid by WebNews, **it too will be removed from the list, along with the
rest of the user's data.**

# Authors

Harlan Haskins ([@harlanhaskins](http://github.com/harlanhaskins))

# Contributors

Mihir Singh ([@citruspi](http://github.com/citruspi))

# Thanks

Alex Grant ([@grantovich](http://github.com/grantovich)) for his
[WebNews API.](https://github.com/grantovich/CSH-WebNews/wiki/API)

# License

This program is released under the MIT License. A copy of this license is available in LICENSE.txt.

# Libraries

This program makes use of [AFNetworking](https://github.com/AFNetworking/AFNetworking),
[PDKeychainBindingsController](https://github.com/carlbrown/PDKeychainBindingsController),
[SAMTextView](https://github.com/soffes/SAMTextView),
[SAMTextField](https://github.com/soffes/SAMTextField),
[SVProgressHUD](https://github.com/samvermette/SVProgressHUD)
and [UIView+Positioning](https://github.com/freak4pc/UIView-Positioning), which are all released under the MIT License,
and [ISO8601DateFormatter](https://github.com/boredzo/iso-8601-date-formatter), released under the BSD license.
