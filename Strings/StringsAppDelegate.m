//
//  StringsAppDelegate.m
//  Strings
//
//  Created by Yuji on 6/18/11.
//  Copyright 2011 東京大学. All rights reserved.
//

#import "StringsAppDelegate.h"
#import "StringsViewController.h"
#import "Reachability.h"

@implementation StringsAppDelegate


@synthesize window=_window,reach;

@synthesize navigationController;
#pragma mark Reachability Warning
- (void) reachabilityChanged: (NSNotification* )note
{
    NetworkStatus status=[self.reach currentReachabilityStatus];
    if(status==NotReachable){
	UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@"Network not available" 
						     message:@"Connetion to the mirror is lost. You can only read previously donwloaded slides." 
						    delegate:nil
					   cancelButtonTitle:@"OK"
					   otherButtonTitles:nil];
	[alert show];
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     
    self.window.rootViewController = self.navigationController;
    self.navigationController.navigationBar.translucent=YES;
    [self.window makeKeyAndVisible];
    
    self.reach=[Reachability reachabilityWithHostName:@"www.sns.ias.edu"];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    [self.reach startNotifier];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


@end
