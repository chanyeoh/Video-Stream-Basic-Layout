//
//  MovieViewController.m
//  stream
//
//  Created by Yeoh Chan on 8/21/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "MovieViewController.h"
#import "DrexelCacheVideoDownloader.h"

@interface MovieViewController ()

@end

@implementation MovieViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
        self.title = @"Loading...";
    [_oneDrive getDownloadLinkFromVideoDao:_vidDAO withBlock:^(NSString *link, NSError *error) {
        self.title = @"Data Load Complete";
        
        cacheLink = link;
        // Start Player
        controllerView = [[DrexelCachePlayer alloc]initWithView:cView withFilename:[NSString stringWithFormat:@"%@.mp4", _vidDAO.fileName] withURL:[NSURL URLWithString:link]];
        
        [controllerView play];
        
        // Start to Cache if CACHE_TIME_SEC interval pass
        [NSTimer scheduledTimerWithTimeInterval:CACHE_TIME_SEC target:self selector:@selector(cacheCounter) userInfo:nil repeats:NO];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cacheCounter{
    NSLog(@"Start the Download");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *outputURL = [documentsDirectory stringByAppendingPathComponent:@"output"] ;
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *mediaFile = [outputURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", _vidDAO.fileName]];
    
    if([manager fileExistsAtPath:mediaFile]){
        NSLog(@"Exists");
        return;
    }
    
    DrexelCacheVideoDownloader *drexelCache = [[DrexelCacheVideoDownloader alloc]initWithFilename:cacheLink withPercentage:0.5];
    [drexelCache extractVideoCompetion:^(NSMutableData *respData) {
        NSLog(@"Complete Download");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *outputURL = [documentsDirectory stringByAppendingPathComponent:@"output"] ;
        [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
        
        outputURL = [outputURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", _vidDAO.fileName]];
        // Remove Existing File
        [manager removeItemAtPath:outputURL error:nil];
        
        
        [respData writeToFile:outputURL atomically:YES];
    }];
}

@end
