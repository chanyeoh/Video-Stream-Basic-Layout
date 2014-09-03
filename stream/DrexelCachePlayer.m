//
//  DrexelCachePlayer.m
//  stream
//
//  Created by Yeoh Chan on 7/25/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "DrexelCachePlayer.h"

@implementation DrexelCachePlayer

-(id)initWithView:(UIView *)view withFilename:(NSString *)filename withURL:(NSURL *)url{
    self = [super init];
    if(self) {
        _filename = filename;
        _url = url;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        NSString *outputURL = [documentsDirectory stringByAppendingPathComponent:@"output"] ;
        [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
        
        outputURL = [outputURL stringByAppendingPathComponent:_filename];
        
        _mcLoad = [[MPMoviePlayerController alloc] initWithContentURL:[[NSURL alloc] initFileURLWithPath:outputURL isDirectory:true]];
        _mcLoad.view.frame = view.bounds;
        
        _mcOnline = [[MPMoviePlayerController alloc] initWithContentURL:url];
        _mcOnline.view.frame = view.bounds;
        [view addSubview:_mcOnline.view];
        [view addSubview:_mcLoad.view];
        
    }
    return self;
}

-(void)play{
    [_mcLoad play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMPMoviePlayerPlaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification  object:_mcLoad];
}


- (void)handleMPMoviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    [_mcOnline setInitialPlaybackTime:_mcLoad.duration * LOAD_AMOUNT];
    
    NSDictionary *notificationUserInfo = [notification userInfo];
    NSNumber *resultValue = [notificationUserInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    MPMovieFinishReason reason = [resultValue intValue];
    if (reason == MPMovieFinishReasonPlaybackError)
    {
        NSError *mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
        if (mediaPlayerError)
        {
            //NSLog(@"playback failed with error description: %@", [mediaPlayerError localizedDescription]);
        }
        else
        {
            //NSLog(@"playback failed without any given reason");
        }
    }
    
    [_mcLoad.view setHidden:YES];
    [_mcOnline play];
}

@end
