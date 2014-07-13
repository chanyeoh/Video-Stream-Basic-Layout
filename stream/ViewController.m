//
//  ViewController.m
//  stream
//
//  Created by Yeoh Chan on 7/12/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "ViewController.h"
#import "LBYouTubeExtractor.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    LBYouTubeExtractor* extractor = [[LBYouTubeExtractor alloc] initWithURL:[NSURL URLWithString:@"http://www.youtube.com/watch?v=1fTIhC1WSew&list=FLEYfH4kbq85W_CiOTuSjf8w&feature=mh_lolz"] quality:LBYouTubeVideoQualityLarge];
    
    [extractor extractVideoURLWithCompletionBlock:^(NSURL *videoURL, NSError *error) {
        if(!error) {
            // TODO videoURL is the url of the extracted video
            // Take a look @ https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/01_UsingAssets.html
            // Look at 'Trimming and Transcoding into a Movie. This would assist you in completing this task. Take
            // 2 -3 days would be able to finish it.
            
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoURL]];
            _mc = [[MPMoviePlayerController alloc]
                                                   initWithContentURL:url];

            _mc.view.frame = self.controllerView.bounds; //Set the size
            
            [self.controllerView addSubview:_mc.view]; //Show the view
            [_mc play]; //Start playing
            
            NSLog(@"Did extract video URL using completion block: %@", videoURL);
        } else {
            NSLog(@"Failed extracting video URL using block due to error:%@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
