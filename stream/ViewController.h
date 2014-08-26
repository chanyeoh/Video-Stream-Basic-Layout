//
//  ViewController.h
//  stream
//
//  Created by Yeoh Chan on 7/12/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeywordAlgorithm.h"
#import "OneDriveFileRetrival.h"

@interface ViewController : UIViewController{
    NSArray *videoArray;
    IBOutlet UITableView *videoTableView;
    
    KeywordAlgorithm *keywordAlgo;
    OneDriveFileRetrival *oneDrive;
}

@end
