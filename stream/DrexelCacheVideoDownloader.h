//
//  DrexelCacheVideoDownloader.h
//  stream
//
//  Created by Yeoh Chan on 7/25/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DrexelCacheVideoDownloaderCompletionBlock)(NSMutableData *respData);

@interface DrexelCacheVideoDownloader : NSObject<NSURLConnectionDelegate>{
    NSMutableData *_responseData;
    NSURLConnection *conn;
    long long _expectedLength;
    long long _totalLength;
}
@property(strong, nonatomic)NSString *url;
@property(readwrite, assign)float percentage;
@property (nonatomic, strong) DrexelCacheVideoDownloaderCompletionBlock completionBlock;

-(id)initWithFilename:(NSString *)filename withPercentage:(float)percentage;
-(void)extractVideoCompetion:(DrexelCacheVideoDownloaderCompletionBlock)completionBlock;
@end
