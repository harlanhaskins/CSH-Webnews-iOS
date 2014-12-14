//
//  AppDelegate.m
//  CSH WebNews
//
//  Created by Harlan Haskins on 8/27/13.
//  Copyright (c) 2013 Haskins. All rights reserved.
//

#import "ActivityViewController.h"
#import "NewsgroupsViewController.h"
#import "APIKeyViewController.h"
#import "AppDelegate.h"
#import "PushAPIHandler.h"
#import "CacheManager.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self respondToUpdate];
    
    UIUserNotificationType notificationType = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType
                                                                                          categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
    
    [ToolBarColorManager setPurpleToolbars];
    
//    [AuthenticationManager invalidateKey];
    
    UISplitViewController *splitController = (UISplitViewController*)self.window.rootViewController;
    splitController.delegate = self;
    splitController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;

    return YES;
}

- (BOOL) splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
   ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return YES;
}

- (BOOL) splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)vc sender:(id)sender {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        if (splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
            UINavigationController *navController = (UINavigationController *)vc;
            UINavigationController *masterNavController = (UINavigationController* )[splitViewController.viewControllers[0] selectedViewController];
            [masterNavController.topViewController showViewController:navController.topViewController sender:sender];
            return YES;
        }
    }
    return NO;
}

- (void) respondToUpdate {
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
    if (!version || ![version isEqualToString:currentVersion]) {
        [CacheManager clearAllCaches];
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"version"];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Reset the badge icon.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Grab the device token's hex value.
    const unsigned *tokenBytes = [deviceToken bytes];
    
    // Create a string using hex format specifiers.
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    [PushAPIHandler sendPushToken:hexToken];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

@end
