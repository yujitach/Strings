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
-(NSString*)sizePath
{
    return [self.cachePath stringByAppendingString:@".size"];
}
-(Downloader*)initWithURL:(NSURL*)_url progress:(DownloadBlock)_dpb done:(DownloadBlock)_dfb;
{
    self=[super init];
    self.url=_url;
    dfb=[_dfb copy];
    dpb=[_dpb copy];
    
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

-(BOOL)fileIsOK
{
    NSFileManager*fm=[[[NSFileManager alloc] init] autorelease];
    if ([fm fileExistsAtPath:self.cachePath]) {
        NSString*size=[NSString stringWithContentsOfFile:self.sizePath encoding:NSUTF8StringEncoding error:NULL];
        NSDictionary*fileDict=[fm attributesOfItemAtPath:self.cachePath error:NULL];
        unsigned long long expectedSize=[fileDict fileSize];
        if([size isEqualToString:[NSString stringWithFormat:@"%lld",expectedSize]]){
            return YES;
        }
//        NSLog(@"The url %@ didn't seem to be nicely downloaded",self.url);
    }
    return NO;
}

-(void)download
{
    NSFileManager*fm=[[NSFileManager alloc] init];
    NSString*cachesFolder=[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSString*fpath=[[url absoluteString] stringByReplacingOccurrencesOfString:@"/" withString:@"@"];
    fpath=[fpath stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    self.cachePath=[cachesFolder stringByAppendingPathComponent:fpath];    
    if(![self fileIsOK]){
	[fm createDirectoryAtPath:cachesFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        [fm createFileAtPath:self.cachePath contents:nil attributes:nil];
        
        NSURLRequest* urlRequest=[NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:300];
        
        fh=[[NSFileHandle fileHandleForWritingAtPath:self.cachePath] retain];
        connection=[[NSURLConnection alloc] initWithRequest:urlRequest
                                                   delegate:self];
        
        
    }else{
        dfb(self);
    }
    [fm release];
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
    [[NSString stringWithFormat:@"%lld",(unsigned long long)expected] writeToFile:self.sizePath atomically:YES];
}
-(void)connectionDidFinishLoading:(NSURLConnection*)c
{
    [fh closeFile];
    if(dfb)dfb(self);
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSFileManager*fm=[[NSFileManager alloc] init];
    [fh closeFile];
    [fm removeItemAtPath:self.cachePath error:NULL];
    [fm release];
}

@end
