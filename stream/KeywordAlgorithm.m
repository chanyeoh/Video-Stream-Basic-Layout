//
//  KeywordAlgorithm.m
//  stream
//
//  Created by Avik Bag on 8/25/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "KeywordAlgorithm.h"

@implementation KeywordAlgorithm

-(id)init{
    self = [super init];
    if(self) {
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

#pragma mark -
#pragma mark Keyword Extraction
-(NSArray *)extractKeywords:(NSString *)keywordText
{
    NSArray *keywordArray =[keywordText componentsSeparatedByString:@"\n"];
    
    NSMutableArray *videoDaoArray = [[NSMutableArray alloc]init];
    NSMutableArray *keywordsArrayForKey = [[NSMutableArray alloc]init];
    
    VideoDAO *videoDao = [[VideoDAO alloc]init];
    
    for(NSString *keys in keywordArray){
        NSString *tempKey = [[keys componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
        
        if([tempKey hasPrefix:@"<iframe"]){
            if(videoDao.fileId != nil){
                videoDao.keywords = [keywordsArrayForKey copy];
                [videoDaoArray addObject:videoDao];
            }
            
            keywordsArrayForKey = [[NSMutableArray alloc]init];
            videoDao = [[VideoDAO alloc]init];
            
            videoDao.fileId = [self getValueFromHtmlSource:tempKey withRegex:@"(<iframesrc=\"(.*?)\")+?"];
            videoDao.fileName = [self getValueFromHtmlSource:tempKey withRegex:@"(name=\"(.*?)\")+?"];
        }else{
            if(![tempKey isEqualToString:@""])
                [keywordsArrayForKey addObject:tempKey];
        }
    }
    
    if(videoDao.fileId != nil){
        videoDao.keywords = [keywordsArrayForKey copy];
        [videoDaoArray addObject:videoDao];
    }
    
    return [videoDaoArray copy];
}

-(NSString *)getValueFromHtmlSource:(NSString *)html withRegex:(NSString *)regexStr{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSArray *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSString *iframeSrc = [html substringWithRange:[match rangeAtIndex:2]] ;
        return iframeSrc;
    }
    return @"";
}



-(void)dataUpdateValuesForKeywords:(NSArray*)keywords
{
    // Compile the values of each keyword as the video cell is tapped.
    NSMutableDictionary* dataSet = [[NSMutableDictionary alloc]initWithDictionary:[userDefaults objectForKey:DICT_DATA]];
    
    if (dataSet == nil || dataSet.count == 0) {
        for (NSString* keyword in keywords) {
            [dataSet setObject:[NSNumber numberWithInt:1] forKey:keyword];
        }
    }
    else{
        for (NSString*keyword in keywords) {
            for (NSString*data in [dataSet allKeys]) {
                if([keyword isEqualToString:data]){
                    NSNumber* value =[NSNumber numberWithInt:([[dataSet objectForKey:keyword] intValue]+1)];
                    [dataSet setObject:value forKey:keyword];
                    
                }
                else if([dataSet objectForKey:keyword] ==nil){
                    [dataSet setObject:[NSNumber numberWithInt:1] forKey:keyword];
                }
            }
        }
    }
    
    [userDefaults setObject:dataSet forKey:DICT_DATA];
    [userDefaults synchronize];
}



-(NSArray *)videoRanking:(NSArray *)vidArray
{
    // Add all the values of the keywords in each video
    NSMutableDictionary* dataSet = (NSMutableDictionary *)[userDefaults objectForKey:DICT_DATA];
    NSMutableDictionary* finalDataArrangement = [[NSMutableDictionary alloc]init];
    
    for (VideoDAO* vid in vidArray){
        NSNumber *calcResult = [[NSNumber alloc]initWithInt:[self getScoreFromKey:[vid keywords] withKeyArray:dataSet]];
        [finalDataArrangement setObject:calcResult forKey:[vid fileId]];
    }
    
    
    return [self sortDictionaryWithObjects:finalDataArrangement withOriginalArray:vidArray];
}



-(int)getScoreFromKey:(NSArray *)keywords withKeyArray:(NSDictionary *)data{
    int calcResult = 0;
    NSArray *storedKeywords = [data allKeys];
    
    for (NSString *kWords in keywords) {
        if([storedKeywords containsObject:kWords]){
            calcResult += [[data objectForKey:kWords] intValue];
        }
    }
    return calcResult;
}

-(NSArray *)sortDictionaryWithObjects:(NSMutableDictionary *)dictionary withOriginalArray:(NSArray *)vidArray{
    NSMutableArray *finalizeArray = [[NSMutableArray alloc]init];
    while (true) {
        NSString *fileIdDict = [self getFileIdFromDictionary:dictionary];
        if(fileIdDict == nil)
            break;
        
        [dictionary removeObjectForKey:fileIdDict];
        
        VideoDAO *newVid =[self searchForVideoDao:vidArray withFileId:fileIdDict];
        if(newVid == nil)
            break;
        [finalizeArray addObject: newVid];
    }
    return [finalizeArray copy];
}

-(NSString *)getFileIdFromDictionary:(NSMutableDictionary *)dictionary{
    NSArray *dictionaryKeys = [dictionary allKeys];
    
    if([dictionaryKeys count] == 0)
        return nil;
    
    NSString* selectedKey = [dictionaryKeys objectAtIndex:0];
    int maxCount = [[dictionary objectForKey:selectedKey] intValue];
    for (NSString *key in dictionaryKeys) {
        int currCount = [[dictionary objectForKey:key] intValue];
        if(currCount > maxCount){
            maxCount = currCount;
            selectedKey = key;
        }
    }
    
    return selectedKey;
}

-(VideoDAO *)searchForVideoDao:(NSArray *)vidArray withFileId:(NSString *)fileId{
    for (VideoDAO *vid in vidArray) {
        if([[vid fileId] isEqualToString:fileId])
            return vid;
    }
    
    return nil;
}

@end
