//
//  MovieViewController.h
//  stream
//
//  Created by Yeoh Chan on 8/21/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrexelCachePlayer.h"
#import "OneDriveFileRetrival.h"
#import "VideoDAO.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MovieViewController : UIViewController{
    IBOutlet UIView *cView;
    MPMoviePlayerController *controllerView;
}

@property(strong, nonatomic)VideoDAO *vidDAO;
@property(strong, nonatomic)OneDriveFileRetrival *oneDrive;
@end
