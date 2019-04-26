//
//  Chooser.h
//  Strings
//
//  Created by Yuji on 6/18/11.
//  Copyright 2011 東京大学. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Chooser : UITableViewController<UINavigationControllerDelegate,UISearchResultsUpdating> {
    NSArray*array;
    NSArray*filtArray;
    NSMutableArray*allData;
    NSString*name;
    BOOL isMain;
    UISearchController*sc;
}
-(Chooser*)initWithDictionary:(NSDictionary*)dict;
@end
