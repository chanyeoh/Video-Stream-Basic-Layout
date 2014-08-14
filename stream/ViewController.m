//
//  ViewController.m
//  stream
//
//  Created by Yeoh Chan on 7/12/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "ViewController.h"
#import "DrexelCachePlayer.h"
#import "DrexelCacheVideoDownloader.h"
#import <AVFoundation/AVFoundation.h>
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize controllerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self postSessionKey];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Play Video (Still Need Fixes)
    /*controllerView = [[DrexelCachePlayer alloc]initWithView:controllerView withFilename:@"output.mp4" withURL:[NSURL URLWithString:@"http://download.wavetlan.com/SVV/Media/HTTP/H264/Talkinghead_Media/H264_test1_Talkinghead_mp4_480x360.mp4"]];
    
    [controllerView play];*/
    
    // Download Cache (Still Need Fixes)
    /*DrexelCacheVideoDownloader *drexelCache = [[DrexelCacheVideoDownloader alloc]initWithFilename:@"http://download.wavetlan.com/SVV/Media/HTTP/H264/Talkinghead_Media/H264_test1_Talkinghead_mp4_480x360.mp4" withPercentage:0.7];
    [drexelCache extractVideoCompetion:^(NSMutableData *respData) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        
        NSString *outputURL = [documentsDirectory stringByAppendingPathComponent:@"output"] ;
        [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
        
        outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
        // Remove Existing File
        [manager removeItemAtPath:outputURL error:nil];
        
        
        [respData writeToFile:outputURL atomically:YES];
    }];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(void)cutImage:(NSURL *)assetURL{
    int startMilliseconds = (0 * 1000);
    int endMilliseconds = (1 * 1000);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *outputURL = [documentsDirectory stringByAppendingPathComponent:@"output"] ;
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    outputURL = [outputURL stringByAppendingPathComponent:@"output1.mp4"];
    [manager removeItemAtPath:outputURL error:nil];
    
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = [[NSURL alloc] initFileURLWithPath:outputURL isDirectory:true] ;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMake(startMilliseconds, 1000), CMTimeMake(endMilliseconds - startMilliseconds, 1000));
    exportSession.timeRange = timeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                // Custom method to import the Exported Video
                //[self loadAssetFromFile:exportSession.outputURL];
                //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoURL]];
                NSLog(@"HERE");
                //_mc.initialPlaybackTime
    
                break;
            case AVAssetExportSessionStatusFailed:
                //
                NSLog(@"Failed:%@",exportSession.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                //
                NSLog(@"Canceled:%@",exportSession.error);
                break;
            default:
                NSLog(@"Error");
                break;
        }
    }];
}
 */
-(void)postSessionKey
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = nil;
    [manager POST:@"https://api.point.io/v2/auth.json?email=drexelProjects%40outlook.com&password=drexelECE&apikey=40958726-AB7A-4679-85C5D142E907CAB1" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"%@", (NSDictionary *)responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSDictionary *resultDict = (NSDictionary *)[dict objectForKey:@"RESULT"];
        NSString *sessionKey = (NSString *)[resultDict objectForKey:@"SESSIONKEY"];
        
        NSLog(@"\n\nSession Key: - %@", sessionKey);
        [self getShareID:sessionKey];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)getShareID:(NSString*)sessionKey
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:sessionKey forHTTPHeaderField:@"Authorization"];
    [manager GET:@"https://api.point.io/v2/accessrules/list.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSArray *columnComponents = (NSArray *)[(NSDictionary *)[responseObject objectForKey:@"RESULT"] objectForKey:@"COLUMNS"];
        NSUInteger shareIDIndex = [columnComponents indexOfObject:@"SHAREID"];
        NSArray *Data = (NSArray *)[(NSDictionary *)[responseObject objectForKey:@"RESULT"] objectForKey:@"DATA"];
        NSArray *DataComponents = [Data objectAtIndex:0];
        NSString *shareID = [DataComponents objectAtIndex:shareIDIndex];
        
        NSLog(@"\n\nShare ID: - %@", shareID);
        [self getFolderList:sessionKey :shareID];
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

-(void)getFolderList:(NSString*)sessionKey:(NSString*)folderID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:sessionKey forHTTPHeaderField:@"Authorization"];
    NSString *requestURL = @"https://api.point.io/v2/folders/list.json";
    requestURL = [requestURL stringByAppendingFormat:@"?folderId=%@",folderID];
    //NSLog(@"%@",requestURL);
    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //Find the index of TYPE within the COLUMN key
         NSArray *columnComponents = (NSArray *)[(NSDictionary *)[responseObject objectForKey:@"RESULT"] objectForKey:@"COLUMNS"];
         NSUInteger typeIndex = [columnComponents indexOfObject:@"TYPE"];
         NSUInteger nameIndex = [columnComponents indexOfObject:@"NAME"];
         NSUInteger fileIDIndex = [columnComponents indexOfObject:@"FILEID"];
         //NSLog(@"Index of TYPE: - %li",(long)typeIndex);
         //NSLog(@"\n\n File List: - %@", responseObject);
         
         //Find the corresponding TYPE values in DATA key
         NSArray *dataComponents = (NSArray *)[(NSDictionary *)[responseObject objectForKey:@"RESULT"] objectForKey:@"DATA"];
         NSUInteger lengthOfDataFiles = [dataComponents count];
         //NSLog(@"No. of DATA files %li",(long)lengthOfDataFiles);
         
         // Loop through the individual subArrays to find corresponding values
         NSMutableArray *typeList = [[NSMutableArray alloc]init];
         NSMutableArray *nameList = [[NSMutableArray alloc]init];
         NSMutableArray *fileIDList = [[NSMutableArray alloc]init];
         for (int i = 0; i<lengthOfDataFiles; i++) {
             NSArray *temp = [dataComponents objectAtIndex:i];
             [typeList addObject:[temp objectAtIndex:typeIndex]];
             [fileIDList addObject:[temp objectAtIndex:fileIDIndex]];
             // To check for the list of dataComponents that have the TYPE "FILE" & and file extension of .mp4
             /*if ([[temp objectAtIndex:typeIndex]  isEqual: @"FILE"] && [[temp objectAtIndex:nameIndex] rangeOfString:@".mp4"].location != NSNotFound) {
                 [nameList addObject:[temp objectAtIndex:nameIndex]];
             }*/
             [nameList addObject:[temp objectAtIndex:nameIndex]];
         }
         NSLog(@"\n File ID list \n%@",fileIDList);
         NSLog(@"\n Name list \n%@",nameList);
         NSLog(@"\n Type List \n%@",typeList);
         //NSLog(@"\n\n File List: - %@", responseObject);
         
         // Obtain FILEID for Keywords.txt
         NSUInteger nameIndexOfKeywords = [nameList indexOfObject:@"Keywords.txt"];
         //NSLog(@"Index of Keywords.txt: - %li",(long)nameIndexOfKeywords);
         NSString *fileIDofKeyword = [fileIDList objectAtIndex:nameIndexOfKeywords];
         NSLog(@"\n File ID list \n%@",fileIDofKeyword);
         
         [self getKeywordDownload:sessionKey :folderID :@"Keywords.txt":fileIDofKeyword];
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

-(void)getKeywordDownload:(NSString*)sessionKey:(NSString*)folderID:(NSString*)fileName:(NSString*)fileID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:sessionKey forHTTPHeaderField:@"Authorization"];
    NSString *requestURL = @"https://api.point.io/v2/folders/files/download.json";
    requestURL = [requestURL stringByAppendingFormat:@"?folderid=%@&filename=%@&fileid=%@",folderID,fileName,fileID];
    //NSLog(@"%@",requestURL);
    
    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"\n\n File List: - %@", responseObject);
         NSString *downloadLink = [responseObject objectForKey:@"RESULT"];
         NSLog(@"\n\n Download URL: - %@", downloadLink);
         NSURL *url = [NSURL URLWithString:downloadLink];
         NSData *textFile = [[NSData alloc]initWithContentsOfURL:url];
         NSString *textfileData = [[NSString alloc] initWithData:textFile encoding:NSASCIIStringEncoding];
         NSLog(@"\n\n%@",textfileData);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];

}

@end
