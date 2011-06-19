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
}
@property (nonatomic, retain) IBOutlet UIImageView*imageView;
@property (nonatomic, retain) IBOutlet UIProgressView*progressView;
@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, retain) NSURL*currentPDFURL;
@property (nonatomic, copy) NSString*speaker;
-(IBAction)pop:(UIBarButtonItem*)sender;
@end
