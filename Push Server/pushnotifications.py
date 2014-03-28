#! /usr/bin/env python
import mongoapi
from apnsclient import *

session = Session.new_connection("push_sandbox", cert_file="newspush.pem")

def sendAlert(tokens, message, count):
    pushMessage = Message(tokens, alert=message, badge=count)
    result = APNs(session).send(pushMessage)
    for token, reason in result.failed.items():
        code, errmsg = reason
        print("Device faled: " + token + " reason: " + errmsg)
        if errmsg == 'Invalid token':
            mongoapi.clearToken(token)

    # Check failures not related to devices.
    for code, errmsg in result.errors:
        print("Error: " + errmsg)

    # Check if there are tokens that can be retried
    if result.needs_retry():
        # repeat with retry_message or reschedule your task
        retry_message = result.retry()

def unreadPostsAlert(unreadCount):
    return "You have %d unread posts." % unreadCount

def unreadInThreadAlert(unreadCount):
    return "You have %d unread posts in threads you've replied to." % unreadCount

def unreadReplyAlert(unreadCount):
    return "You have %d unread replies." % unreadCount

def sendUnreadPostsAlert(unreadCount, tokens):
    sendAlert(tokens, unreadPostsAlert(unreadCount), unreadCount)

def sendUnreadInThreadAlert(unreadCount, tokens):
    sendAlert(tokens, unreadInThreadAlert(unreadCount), unreadCount)

def sendUnreadReplyAlert(unreadCount, tokens):
    sendAlert(tokens, unreadReplyAlert(unreadCount), unreadCount)
