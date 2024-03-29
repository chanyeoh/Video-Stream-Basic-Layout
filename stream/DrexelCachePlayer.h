//
//  DrexelCachePlayer.h
//  stream
//
//  Created by Yeoh Chan on 7/25/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#define LOAD_AMOUNT 0.5

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface DrexelCachePlayer : UIView{
    bool switched;
    MPMoviePlayerController* _mcLoad;
    MPMoviePlayerController* _mcOnline;
}

@property(strong ,nonatomic)NSString *filename;
@property(strong, nonatomic)NSURL *url;

-(id)initWithView:(UIView *)view withFilename:(NSString *)filename withURL:(NSURL *)url;
-(void)play;
@end
