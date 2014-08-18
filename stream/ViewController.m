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
#import "OneDriveFileRetrival.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize controllerView;

- (void)viewDidLoad
{
    [super viewDidLoad];


    self.title = @"Loading...";
    OneDriveFileRetrival *oneDrive = [[OneDriveFileRetrival alloc]init];
    [oneDrive getFileList:^(NSArray *fileList, NSString *keywordsText, NSError *error) {
        if(error){
            self.title = @"Error On Loading...";
            return;
        }
        NSLog(@"%@", keywordsText);
        
        _videoArray = fileList;
        [videoTableView reloadData];
        self.title = @"Data Load Complete...";
        
        NSLog(@"%@", [self keywordAlgorithm:keywordsText]);
    }];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(NSDictionary *)keywordAlgorithm:(NSString *)keywordText
{
    
    //NSString *newKeywordText = [keywordText stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];

    NSArray *keywordArray =[keywordText componentsSeparatedByString:@"\n"];
    
    NSString *lastKey = nil;
    NSMutableDictionary *frameDictionary = [[NSMutableDictionary alloc]init];
    NSMutableArray *keywordsArrayForKey = [[NSMutableArray alloc]init];
    
    for(NSString *keys in keywordArray){
        NSString *tempKey = [[keys componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
     
        if([tempKey hasPrefix:@"<iframe"]){
            if(lastKey){
                [frameDictionary setObject:keywordsArrayForKey forKey:lastKey];
            }
            keywordsArrayForKey = [[NSMutableArray alloc]init];
            lastKey = [self getFrameSource:tempKey];
        }else{
            if(![tempKey isEqualToString:@""])
                [keywordsArrayForKey addObject:tempKey];
        }
    }
    
    if(lastKey){
        [frameDictionary setObject:keywordsArrayForKey forKey:lastKey];
    }
    return frameDictionary;
}

-(NSString *)getFrameSource:(NSString *)html{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<iframesrc=\"(.*?)\")+?"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSArray *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSString *iframeSrc = [html substringWithRange:[match rangeAtIndex:2]] ;
        return iframeSrc;
    }
    return @"";
}


#pragma mark -
#pragma mark Table View Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_videoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_videoArray objectAtIndex:indexPath.row];
    return cell;
}








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


@end
