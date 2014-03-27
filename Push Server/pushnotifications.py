import mongoapi
from apnsclient import *

session = Session.connect("feedback_sandbox", cert_file="newspush.pem")

def sendAlert(tokens, message, count):
    pushMessage = Message(tokens, alert=message, badge=count)
    result = APNs(session).send(pushMessage)
    for token, reason in result.failed.items():
        code, errmsg = reason
        print("Device faled: {0}, reason: {1}".format(token, errmsg))

    # Check failures not related to devices.
    for code, errmsg in res.errors:
        print("Error: " + errmsg)

def unreadPostsAlert(unreadCount):
    return "You have %d unread posts." % unreadCount

def unreadInThreadAlert(unreadCount):
    return "You have %d unread posts in threads you've replied to." % unreadCount

def unreadReplyAlert(unreadCount):
    return "You have %d unread replies." % unreadCount

def sendUnreadPostsAlert(unreadCount, token):
    sendAlert(token, unreadPostsAlert(unreadCount))

def sendUnreadInThreadAlert(unreadCount, token):
    sendAlert(token, unreadInThreadAlert(unreadCount))

def sendUnreadReplyAlert(unreadCount, token):
    sendAlert(token, unreadReplyAlert(unreadCount))
