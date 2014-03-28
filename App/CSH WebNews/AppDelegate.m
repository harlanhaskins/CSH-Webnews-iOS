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
#import "SelectivelyRotatingNavigationController.h"
#import "SelectivelyRotatingTabBarController.h"
#import "PushAPIHandler.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"57f8a290-0abe-4a6c-8e31-cc74dabf6b99"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[self class] viewController];
    
//    [[PDKeychainBindings sharedKeychainBindings] setObject:@"NULL_API_KEY" forKey:kApiKeyKey];
    
    [application registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [self.window makeKeyAndVisible];
    return YES;
}

+ (UIViewController*) viewController {
    ActivityViewController *activityViewController = [ActivityViewController new];
    
    SelectivelyRotatingNavigationController *activityNavController = [[SelectivelyRotatingNavigationController alloc] initWithRootViewController:activityViewController];
    
    NewsgroupsViewController *newsgroupsViewController = [NewsgroupsViewController new];
    
    SelectivelyRotatingNavigationController *newsgroupNavController = [[SelectivelyRotatingNavigationController alloc] initWithRootViewController:newsgroupsViewController];
    
    SelectivelyRotatingTabBarController *tabViewController = [SelectivelyRotatingTabBarController new];
    tabViewController.viewControllers = @[activityNavController, newsgroupNavController];
    
    
    
    return tabViewController;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
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
    
    [PushAPIHandler sendPushToken:hexToken withSuccess:^(AFHTTPRequestOperation *op, id response) {
        NSLog(@"Response: %@", response);
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

@end
