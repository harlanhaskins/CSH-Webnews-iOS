#!/usr/bin/env python

# Search the current directory and the directory above.
import sys
sys.path.append('..')
sys.path.append('.')

import api

import random
import string

api.database = api.MongoClient().webnewsios.testUsers

pool = string.ascii_lowercase + string.digits

api.clearUsers()

keys = ["testing?", "hello", "dolly"]
for x in range(10):
    random_token    = ''.join(random.choice(pool) for x in range(16))
    random_api_key  = keys[int(random.random() * len(keys))]

    api.insertUser(random_token, random_api_key)

api.printUsers()
