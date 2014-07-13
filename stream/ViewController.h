//
//  ViewController.h
//  stream
//
//  Created by Yeoh Chan on 7/12/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController

@property (nonatomic,strong) IBOutlet UIView *controllerView;
@property (nonatomic,strong) MPMoviePlayerController* mc;
@end
