//
//  ArXivPDFDownloader.h
//  arXiver
//
//  Created by Yuji on 6/20/10.
//  Copyright 2010 Y. Tachikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Downloader;
typedef void (^DownloadBlock)(Downloader*d);
@interface Downloader : NSObject {
    
    NSURLConnection*connection;
    NSURLResponse*response;
    NSFileHandle*fh;
    long long sofar;
    long long expected;

    DownloadBlock dfb;
    DownloadBlock dpb;
}
-(Downloader*)initWithURL:(NSURL*)_url progress:(DownloadBlock)_dpb done:(DownloadBlock)_dfb;
-(void)download;

@property (nonatomic, retain) NSString*cachePath;
@property (nonatomic, retain) NSURL*url;
@property (nonatomic, readonly) NSURL*fileURL;
@property (nonatomic, readonly) float progress;
@end
