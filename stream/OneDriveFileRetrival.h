//
//  OneDriveFileRetrival.h
//  stream
//
//  Created by Yeoh Chan on 8/14/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDAO.h"

#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

typedef void (^OneDriveFileRetrivalCompletionBlock)(NSArray *fileList, NSString *keywordsText, NSError *error);
typedef void (^OneDriveFileRetrivalSessionKeyBlock)(NSString *sessionKey, NSError *error);
typedef void (^OneDriveFileRetrivalShareIdBlock)(NSString *shareId, NSError *error);
typedef void (^OneDriveFileRetrivalKeywordsTextBlock)(NSString *keywords, NSError *error);
typedef void (^OneDriveFileRetrivalUrlLinkBlock)(NSString *link, NSError *error);
typedef void (^OneDriveFileRetrivalVideListBlock)(NSArray *mp4FileList, NSString *keywordFileId, NSError *error);

@interface OneDriveFileRetrival : NSObject{
    NSString *_sessionKey;
    AFHTTPRequestOperationManager *_manager;
}

@property (nonatomic, strong) OneDriveFileRetrivalCompletionBlock completionBlock;

-(id)initWithSessionKey:(NSString *)sessionKey;
-(void)getFileList:(OneDriveFileRetrivalCompletionBlock)completionBlock;
-(void)getDownloadLinkFromVideoDao:(VideoDAO *)video withBlock:(OneDriveFileRetrivalUrlLinkBlock) completionBlock;
@end