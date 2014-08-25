//
//  KeywordAlgorithm.h
//  stream
//
//  Created by Avik Bag on 8/25/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeywordAlgorithm : NSObject
{
    NSDictionary *srcDictionary;
    NSArray *videoArray;

}

-(NSDictionary *)keywordAlgorithm:(NSString *)keywordText;
-(void)videoRanking;
-(int)getScoreFromKey:(NSArray *)keywords withKeyArray:(NSDictionary *)data;
-(void)dataUpdateValuesForKeywords:(NSArray*)keywords;

@end
