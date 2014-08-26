///Users/yeohchan/Movies/stream/stream.xcodeproj
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
#import "SimpleTableCell.h"
#import "MovieViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Loading...";
    
    keywordAlgo = [[KeywordAlgorithm alloc]init];
    oneDrive = [[OneDriveFileRetrival alloc]init];
    
    [oneDrive getFileList:^(NSArray *fileList, NSString *keywordsText, NSError *error) {
        if(error){
            self.title = @"Error On Loading...";
            return;
        }
        
        videoArray = [keywordAlgo videoRanking:[keywordAlgo extractKeywords:keywordsText]];
        [videoTableView reloadData];
        
        self.title = @"Data Load Complete";
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    if(videoArray != nil){
        videoArray = [keywordAlgo videoRanking:videoArray];
        [videoTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark Table View Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    VideoDAO *vidDao = [videoArray objectAtIndex:indexPath.row];
    cell.videoLabel.text = [vidDao fileName];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    VideoDAO *vidDao = [videoArray objectAtIndex:indexPath.row];
    [keywordAlgo dataUpdateValuesForKeywords:vidDao.keywords];
    
    
    MovieViewController *movieViewController = [sb instantiateViewControllerWithIdentifier:@"MovieViewController"];
    movieViewController.oneDrive = oneDrive;
    movieViewController.vidDAO = vidDao;
    [self.navigationController pushViewController:movieViewController animated:YES];
    
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
