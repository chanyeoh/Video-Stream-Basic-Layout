//
//  KeywordAlgorithm.h
//  stream
//
//  Created by Avik Bag on 8/25/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDAO.h"

#define DICT_DATA @"data"

@interface KeywordAlgorithm : NSObject{
    NSUserDefaults* userDefaults;
}

-(NSArray *)extractKeywords:(NSString *)keywordText;
-(NSArray *)videoRanking:(NSArray *)keyArray;
-(void)dataUpdateValuesForKeywords:(NSArray*)keywords;
@end
