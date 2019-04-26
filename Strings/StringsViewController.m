//
//  StringsViewController.m
//  Strings
//
//  Created by Yuji on 6/18/11.
//  Copyright 2011 東京大学. All rights reserved.
//

#import "StringsViewController.h"
#import "Chooser.h"
#import "Downloader.h"

@implementation StringsViewController
@synthesize imageView,popoverController,sharePopoverController,progressView;
@synthesize speaker,currentPDFURL,share;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)pop:(UIBarButtonItem*)sender
{
    [popoverController presentPopoverFromBarButtonItem:sender
			      permittedArrowDirections:UIPopoverArrowDirectionUp 
					      animated:YES];
}
#pragma mark - Business Logic
-(UIImage*)imageAtPageNumber:(NSUInteger)pageNumber
{
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage (currentPDF, pageNumber);
    CGRect cropBox= CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox) ; 
    CGRect mediaBox= CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox) ; 
    CGRect target;
    CGFloat scale=[UIScreen mainScreen].scale;
    if(cropBox.size.height>cropBox.size.width){
            target=CGRectMake(0,0,768*scale,1024*scale);            
    }else{
            target=CGRectMake(0,0,1024*scale,768*scale);        
    }
    float ratio=target.size.height/cropBox.size.height;
    float wratio=target.size.width/cropBox.size.width;
    if(wratio<ratio)ratio=wratio;
    float theight=ratio*cropBox.size.height;
    float twidth=ratio*cropBox.size.width;
    unsigned char *bitmap = malloc(target.size.width * target.size.height * sizeof(unsigned char) *4);
    CGColorSpaceRef deviceRGB=CGColorSpaceCreateDeviceRGB();
    CGContextRef context =CGBitmapContextCreate(bitmap,
                          target.size.width,
                          target.size.height,
                          8,
                          target.size.width * 4,
                          deviceRGB,
                          kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(deviceRGB);
    CGContextSetCMYKFillColor(context, 0, 0, 0, 0, 1);
    CGContextTranslateCTM(context, 0,target.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, (target.size.width-twidth)/2,(target.size.height-theight)/2);
    CGContextFillRect(context,CGRectMake(0, 0, twidth, theight));
    CGContextScaleCTM(context, ratio, ratio);
    CGContextTranslateCTM(context, -(mediaBox.size.width-cropBox.size.width),-(mediaBox.size.height-cropBox.size.height));
//    CGContextClipToRect(context, CGRectMake(0,0, cropBox.size.width, cropBox.size.height));
    CGContextDrawPDFPage (context, pdfPage);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmap);
    int rotation=CGPDFPageGetRotationAngle(pdfPage);
    UIImageOrientation orientation=UIImageOrientationDownMirrored;
    if(rotation==90){
        orientation=UIImageOrientationLeftMirrored;        
    }else if(rotation==180){
        orientation=UIImageOrientationUpMirrored;        
    }else if(rotation==270){
        orientation=UIImageOrientationRightMirrored;
    }
    UIImage*image=[UIImage imageWithCGImage:cgImage scale:scale orientation:orientation];
    CGImageRelease(cgImage);
    return image;
}
-(void)loadPage
{
    UIImage*image=[self imageAtPageNumber:currentPage];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [imageView setImage:image];
    self.navigationItem.title=[NSString stringWithFormat:@"%@, %d of %d",self.speaker,(int)currentPage,(int)pages];
}
-(void)minusonepage
{
    if(!progressView.hidden)
        return;
    currentPage--;
    if(currentPage<1){
        currentPage=1;
    }else{
        [self loadPage];
    }    
}
-(void)plusonepage
{
    if(!progressView.hidden)
        return;
    currentPage++;
    if(currentPage>pages){
        currentPage=pages;
    }else{
        [self loadPage];
    }    
}
-(void)bringupmenu{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch*t=[[touches objectEnumerator] nextObject];
    CGPoint point=[t locationInView:self.view];
    CGSize size=self.view.bounds.size;
    CGFloat posX=point.x/size.width;
    if(posX<.3){
        [self minusonepage];
    }else if(posX>.7){
        [self plusonepage];
    }else{
        [self bringupmenu];
    }
}
-(IBAction)longPressed:(id)sender
{
    [self bringupmenu];
}
-(IBAction)swipedLeft:(id)sender
{
    [self plusonepage];
}
-(IBAction)swipedRight:(id)sender
{
    [self minusonepage];
}
-(IBAction)share:(UIBarButtonItem*)shareButton
{
    NSString*comment=[NSString stringWithFormat:@"Check out the talk by %@ in %@: %@",entry[@"name"],entry[@"parentName"],entry[@"target"]];
    UIActivityViewController*avc=[[UIActivityViewController alloc] initWithActivityItems:@[comment] applicationActivities:nil];
    sharePopoverController=[[UIPopoverController alloc] initWithContentViewController:avc];
    [sharePopoverController presentPopoverFromBarButtonItem:shareButton
			      permittedArrowDirections:UIPopoverArrowDirectionUp
					      animated:YES];
    
}
-(void)loadPDF:(NSURL*)fileURL
{
    if(currentPDF){
        CGPDFDocumentRelease(currentPDF);
    }
    currentPDF=CGPDFDocumentCreateWithURL((__bridge CFURLRef)fileURL);
    pages=CGPDFDocumentGetNumberOfPages(currentPDF);
    currentPage=1;
    [self loadPage];
}
-(void)openPDF:(NSNotification*)notification
{
    entry=notification.object;
    [popoverController dismissPopoverAnimated:YES];
    share.enabled=YES;
    self.speaker=entry[@"name"];
    self.navigationItem.title=self.speaker;
    NSString*quotedURL=[(NSString*)entry[@"target"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    self.currentPDFURL=[NSURL URLWithString:quotedURL];
    BOOL downloading=NO;
    for(Downloader*x in downloaders){
//        NSLog(@"%@ is downloading...",x.url);
        if([x.url isEqual:self.currentPDFURL]){
            downloading=YES;
//            NSLog(@"download of %@ already going on!",self.currentPDFURL);
            break;
        }
    }
    if(!downloading){
        Downloader *downloader=[[Downloader alloc] 
                                initWithURL:self.currentPDFURL
                                progress:^(Downloader*d){
                                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                                    if([d.url isEqual:self.currentPDFURL]){
                                        progressView.hidden=NO;
                                        progressView.progress=d.progress;
                                        imageView.alpha=.5;
                                    }
                                }done:^(Downloader*d){
                                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                    if([d.url isEqual:self.currentPDFURL]){
                                        progressView.hidden=YES;
                                        imageView.alpha=1;
                                        [self loadPDF:d.fileURL];
                                    }
                                    [downloaders removeObject:d];
                                }];
        [downloaders addObject:downloader];
        [downloader download];
    }
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem*button=[[UIBarButtonItem alloc] initWithTitle:@"Slides" style:UIBarButtonItemStylePlain target:self action:@selector(pop:)];
    self.navigationItem.leftBarButtonItem=button;
    self.navigationItem.title=@"";

    share=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    share.enabled=NO;
    self.navigationItem.rightBarButtonItem=share;
    
    NSURL*mainPlist=[[NSBundle mainBundle] URLForResource:@"Conferences" withExtension:@"plist"];
    NSDictionary*dict=[NSDictionary dictionaryWithContentsOfURL:mainPlist];
    
    Chooser*chooser=[[Chooser alloc] initWithDictionary:dict];
    UINavigationController*nvc=[[UINavigationController alloc] initWithRootViewController:chooser];
    UIPopoverController*pc=[[UIPopoverController alloc] initWithContentViewController:nvc];
    self.popoverController = pc;
    self.popoverController.contentViewController.preferredContentSize=CGSizeMake(500, 900);

    downloaders=[[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPDF:) name:@"openPDF" object:nil];
    
    UILongPressGestureRecognizer*r=[[UILongPressGestureRecognizer alloc] initWithTarget:self
									 action:@selector(longPressed:)];
    [self.view addGestureRecognizer:r];
    UISwipeGestureRecognizer*swL=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    swL.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swL];
    UISwipeGestureRecognizer*swR=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    swR.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swR];

    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
