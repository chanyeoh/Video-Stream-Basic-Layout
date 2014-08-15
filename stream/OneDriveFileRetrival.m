//
//  OneDriveFileRetrival.m
//  stream
//
//  Created by Yeoh Chan on 8/14/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "OneDriveFileRetrival.h"

@implementation OneDriveFileRetrival

#pragma mark -
#pragma mark Public Methods
/**
 Init Method that creates a session key
 Programmer: Chan Yeoh
 Last Modified Date: August 15, 2014
 */
-(id)initWithSessionKey:(NSString *)sessionKey{
    self = [super init];
    if(self) {
        _sessionKey = sessionKey;
    }
    return self;
}

/**
 Method that serves to get the File List
 Programmer: Chan Yeoh
 Last Modified Date: August 15, 2014
 */
-(void)getFileList:(OneDriveFileRetrivalCompletionBlock)completionBlock{
    _manager = [AFHTTPRequestOperationManager manager];
    
    if(_sessionKey == nil){
        [self getSessionKey:^(NSString *sessionKey, NSError *error) {
            if(error){
                completionBlock(nil, nil, error);
                return;
            }
            
            _sessionKey = sessionKey;
            [self getFolderList:completionBlock];
        }];
        return;
    }
    [self getFolderList:completionBlock];
}

#pragma mark -
#pragma mark Private Methods
/**
 Method that is used for the completion block of videos and keywords
 Programmer: Avik Bag
 Last Modified Date: August 15, 2014
 */
-(void)getFolderList:(OneDriveFileRetrivalCompletionBlock)completionBlock{
    [self getShareID:^(NSString *shareId, NSError *error) {
        if(error){
            completionBlock(nil, nil, error);
            return;
        }
        [self getFolderFileList:shareId withBlock:^(NSArray *mp4FileList, NSString *keywordFileId, NSError *error) {
            if(error){
                completionBlock(nil, nil, error);
                return;
            }
            
            [self getKeywordDownload:shareId withFilename:@"Keywords.txt" withFileId:keywordFileId withKeywordsBlock:^(NSString *keywords, NSError *error) {
                completionBlock(nil, nil, error);
                if(error){
                    return;
                }
                completionBlock(mp4FileList, keywords, nil);
            }];
            
        }];
    }];
}

/**
 Method that is used to get the session key
 Programmer: Avik Bag
 Last Modified Date: August 15, 2014
 */
-(void)getSessionKey:(OneDriveFileRetrivalSessionKeyBlock)sessionKeyBlock
{
    NSDictionary *parameters = nil;
    [_manager POST:@"https://api.point.io/v2/auth.json?email=drexelProjects%40outlook.com&password=drexelECE&apikey=40958726-AB7A-4679-85C5D142E907CAB1" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSDictionary *resultDict = (NSDictionary *)[dict objectForKey:@"RESULT"];
        
        sessionKeyBlock((NSString *)[resultDict objectForKey:@"SESSIONKEY"], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        sessionKeyBlock(nil, error);
    }];
}


/**
 Method tthat is used to get the share id of the folder
 Programmer: Avik Bag
 Last Modified Date: August 15, 2014
 */
-(void)getShareID:(OneDriveFileRetrivalShareIdBlock)shareIdBlock
{
    [_manager.requestSerializer setValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    [_manager GET:@"https://api.point.io/v2/accessrules/list.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *columnComponents = (NSArray *)[(NSDictionary *)[responseObject objectForKey:@"RESULT"] objectForKey:@"COLUMNS"];
        NSUInteger shareIDIndex = [columnComponents indexOfObject:@"SHAREID"];
        NSArray *data = (NSArray *)[(NSDictionary *)[responseObject objectForKey:@"RESULT"] objectForKey:@"DATA"];
        NSArray *dataComponents = [data objectAtIndex:0];
        NSString *shareID = [dataComponents objectAtIndex:shareIDIndex];
        shareIdBlock(shareID, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            shareIdBlock(nil, error);
         }];
}

/**
 Method that is used to get the list of folders/files
 Programmer: Avik Bag
 Last Modified Date: August 15, 2014
 */
-(void)getFolderFileList:(NSString*)folderID withBlock:(OneDriveFileRetrivalVideListBlock)videoBlock
{
    [_manager.requestSerializer setValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSString *requestURL = @"https://api.point.io/v2/folders/list.json";
    requestURL = [requestURL stringByAppendingFormat:@"?folderId=%@",folderID];
    [_manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //Find the index of TYPE within the COLUMN key
         NSArray *columnComponents = (NSArray *)[(NSDictionary *)[responseObject objectForKey:@"RESULT"] objectForKey:@"COLUMNS"];
         NSUInteger typeIndex = [columnComponents indexOfObject:@"TYPE"];
         NSUInteger nameIndex = [columnComponents indexOfObject:@"NAME"];
         NSUInteger fileIDIndex = [columnComponents indexOfObject:@"FILEID"];
         
         //Find the corresponding TYPE values in DATA key
         NSArray *dataComponents = (NSArray *)[(NSDictionary *)[responseObject objectForKey:@"RESULT"] objectForKey:@"DATA"];
         NSUInteger lengthOfDataFiles = [dataComponents count];
         
         // Loop through the individual subArrays to find corresponding values
         NSMutableArray *typeList = [[NSMutableArray alloc]init];
         NSMutableArray *nameList = [[NSMutableArray alloc]init];
         NSMutableArray *fileIDList = [[NSMutableArray alloc]init];
         NSString *keywordsTxt = @"";
         for (int i = 0; i<lengthOfDataFiles; i++) {
             NSArray *temp = [dataComponents objectAtIndex:i];
             [typeList addObject:[temp objectAtIndex:typeIndex]];
             [fileIDList addObject:[temp objectAtIndex:fileIDIndex]];
             // To check for the list of dataComponents that have the TYPE "FILE" & and file extension of .mp4
             if ([[temp objectAtIndex:typeIndex]  isEqual: @"FILE"] && [[temp objectAtIndex:nameIndex] rangeOfString:@".mp4"].location != NSNotFound) {
              [nameList addObject:[temp objectAtIndex:nameIndex]];
              }
             if([[temp objectAtIndex:nameIndex] isEqualToString:@"Keywords.txt"]){
                 keywordsTxt = [temp objectAtIndex:fileIDIndex];
             }
         }
         videoBlock(nameList, keywordsTxt, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         videoBlock(nil, nil, error);
     }];
}


/**
 Method that is used to download the keyword.txt
 Programmer: Avik Bag
 Last Modified Date: August 15, 2014
 */
-(void)getKeywordDownload:(NSString*)folderID withFilename:(NSString*)fileName withFileId:(NSString*)fileID
        withKeywordsBlock:(OneDriveFileRetrivalKeywordsTextBlock)keywordBlock
{
    [_manager.requestSerializer setValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSString *requestURL = @"https://api.point.io/v2/folders/files/download.json";
    requestURL = [requestURL stringByAppendingFormat:@"?folderid=%@&filename=%@&fileid=%@",folderID,fileName,fileID];
    
    [_manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSString *downloadLink = [responseObject objectForKey:@"RESULT"];
         NSURL *url = [NSURL URLWithString:downloadLink];
         NSData *textFile = [[NSData alloc]initWithContentsOfURL:url];
         NSString *textfileData = [[NSString alloc] initWithData:textFile encoding:NSASCIIStringEncoding];
         
         keywordBlock(textfileData, nil);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             keywordBlock(nil, error);
         }];
    
}
@end
