//
//  StringsAppDelegate.h
//  Strings
//
//  Created by Yuji on 6/18/11.
//  Copyright 2011 東京大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StringsViewController;
@class Reachability;
@interface StringsAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) Reachability *reach;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
