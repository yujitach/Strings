//
//  StringsViewController.h
//  Strings
//
//  Created by Yuji on 6/18/11.
//  Copyright 2011 東京大学. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Downloader;
@interface StringsViewController : UIViewController {
    NSMutableArray*downloaders;
    CGPDFDocumentRef currentPDF;
    NSUInteger pages;
    NSUInteger currentPage;
    NSDictionary*entry;
}
@property (nonatomic, strong) IBOutlet UIImageView*imageView;
@property (nonatomic, strong) IBOutlet UIProgressView*progressView;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UIBarButtonItem*share;

@property (nonatomic, strong) NSURL*currentPDFURL;
@property (nonatomic, copy) NSString*speaker;
-(IBAction)pop:(UIBarButtonItem*)sender;
@end
