//
//  Chooser.h
//  Strings
//
//  Created by Yuji on 6/18/11.
//  Copyright 2011 東京大学. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Chooser : UITableViewController<UINavigationControllerDelegate> {
    NSArray*array;
    NSString*name;
}
-(Chooser*)initWithDictionary:(NSDictionary*)dict;
@end
