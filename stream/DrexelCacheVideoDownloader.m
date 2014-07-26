//
//  DrexelCacheVideoDownloader.m
//  stream
//
//  Created by Yeoh Chan on 7/25/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "DrexelCacheVideoDownloader.h"

@implementation DrexelCacheVideoDownloader

-(id)initWithFilename:(NSString *)url withPercentage:(float)percentage{
    self = [super init];
    if(self) {
        _url = url;
        _percentage = percentage;
    }
    return self;
}

-(void)extractVideoCompetion:(DrexelCacheVideoDownloaderCompletionBlock)completionBlock{
    self.completionBlock = completionBlock;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
    // Create url connection and fi re request
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _totalLength = 0;
    _responseData = [[NSMutableData alloc] init];
    _expectedLength = response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    _totalLength += [data length];
    [_responseData appendData:data];
    float percentage = (_totalLength / (float)_expectedLength);
    NSLog(@"Progress: %f", percentage*100);
    if(percentage >= _percentage){
        [conn cancel];
        
        self.completionBlock(_responseData);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    self.completionBlock(_responseData);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    self.completionBlock(nil);
}

@end
