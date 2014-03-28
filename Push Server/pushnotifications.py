#! /usr/bin/env python
import mongoapi
from apnsclient import *

session = Session.new_connection("push_sandbox", cert_file="newspush.pem")

def sendAlert(tokens, message, count):
    """
    Sends the passed in message to the device tokens provided using the APNs
    server.
    Also sends a count of unread messages as a badge.
    """
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
    """
    Returns an alert that tells a number of unread posts.
    """
    post = "post" if unreadCount == 1 else "posts"
    return ("You have %d new unread " + post + ".") % unreadCount

def unreadInThreadAlert(unreadCount):
    """
    Returns an alert that tells a number of unread posts in a thread to which
    that user has posted.
    """
    post = "post" if unreadCount == 1 else "posts"
    return ("You have %d new unread " + post + " in threads you've replied to.") % unreadCount

def unreadReplyAlert(unreadCount):
    """
    Returns an alert that tells a number of unread replies to a user's post.
    """
    reply = "reply" if unreadCount == 1 else "replies"
    return ("You have %d new unread " + reply + ".") % unreadCount

def sendUnreadPostsAlert(tokens, newUnreadCount, totalUnreadCount):
    """
    Sends an unreadPostsAlert.
    """
    sendAlert(tokens, unreadPostsAlert(newUnreadCount), totalUnreadCount)

def sendUnreadInThreadAlert(tokens, newUnreadCount, totalUnreadCount):
    """
    Sends an unreadInThreadAlert.
    """
    sendAlert(tokens, unreadInThreadAlert(newUnreadCount), totalUnreadCount)

def sendUnreadReplyAlert(tokens, newUnreadCount, totalUnreadCount):
    """
    Sends an unreadReplyAlert.
    """
    sendAlert(tokens, unreadReplyAlert(newUnreadCount), totalUnreadCount)
