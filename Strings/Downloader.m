//
//  ArXivPDFDownloader.m
//  arXiver
//
//  Created by Yuji on 6/20/10.
//  Copyright 2010 Y. Tachikawa. All rights reserved.
//

#import "Downloader.h"


@implementation Downloader
@synthesize cachePath,url;
-(NSURL*)fileURL
{
    return [NSURL fileURLWithPath:cachePath];
}
-(float)progress
{
    if(expected)
        return (float)sofar/(float)expected;
    else
        return 0;
}
-(Downloader*)initWithURL:(NSURL*)_url progress:(DownloadBlock)_dpb done:(DownloadBlock)_dfb;
{
    self=[super init];
    self.url=_url;
    dfb=[_dfb copy];
    dpb=[_dpb copy];
    
    NSString*cachesFolder=[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSString*fpath=[[url absoluteString] stringByReplacingOccurrencesOfString:@"/" withString:@"@"];
    fpath=[fpath stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    self.cachePath=[cachesFolder stringByAppendingPathComponent:fpath];
    NSLog(@"%@",self.cachePath);
    NSFileManager*fm=[[NSFileManager alloc] init];
    if(![fm fileExistsAtPath:self.cachePath]){
	[fm createDirectoryAtPath:cachesFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        [fm createFileAtPath:self.cachePath contents:nil attributes:nil];
        [self download];
    }else{
        dfb(self);
    }
    [fm release];
    
    return self;
}

-(void)dealloc
{
    [url release];
    [dfb release];
    [dpb release];
    [cachePath release];
    [fh release];
    [connection release];
    [response release];
    [super dealloc];
}

-(void)download
{
//    NSLog(@"fetching:%@",url);
    NSURLRequest* urlRequest=[NSURLRequest requestWithURL:url
					      cachePolicy:NSURLRequestUseProtocolCachePolicy
					  timeoutInterval:300];
    
    fh=[[NSFileHandle fileHandleForWritingAtPath:self.cachePath] retain];
    connection=[[NSURLConnection alloc] initWithRequest:urlRequest
					       delegate:self];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
-(void)connection:(NSURLConnection *)c didReceiveData:(NSData *)data
{
    [fh writeData:data];
    sofar+=[data length];
    if(dpb)dpb(self);
}
-(void)connection:(NSURLConnection*)c didReceiveResponse:(NSURLResponse*)resp
{
    response=[resp retain];
    expected=response.expectedContentLength;
}
-(void)connectionDidFinishLoading:(NSURLConnection*)c
{
    [fh closeFile];
    if(dfb)dfb(self);
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
