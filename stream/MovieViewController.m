//
//  MovieViewController.m
//  stream
//
//  Created by Yeoh Chan on 8/21/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "MovieViewController.h"

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
        
        controllerView = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:link]];
        controllerView.view.frame = cView.bounds;
        [cView addSubview:controllerView.view];
        
        [controllerView play];

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
