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
        NSLog(@"%@", error);
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
    cell.valueLabel.text = [NSString stringWithFormat:@"%d", [keywordAlgo getScoreFromKey:[vidDao keywords] withKeyArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"data"]]];
    
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


@end
