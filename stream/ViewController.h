//
//  ViewController.h
//  stream
//
//  Created by Yeoh Chan on 7/12/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrexelCachePlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController{
    NSArray *_videoArray;
    NSDictionary *srcDictionary;
    IBOutlet UITableView *videoTableView;
}

@property (nonatomic,strong) IBOutlet DrexelCachePlayer *controllerView;
@end
