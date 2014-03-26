import mongoapi
from apns import APNs, Payload

apns = APNs(use_sandbox=True, cert_file='cert.pem', key_file='key.pem')

def sendAlert(token, message):
    payload = Payload(alert=message, sound="default", badge=1)
    apns.gateway_server.send_notification(token, payload)

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
