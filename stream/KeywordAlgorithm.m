//
//  KeywordAlgorithm.m
//  stream
//
//  Created by Avik Bag on 8/25/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "KeywordAlgorithm.h"

@implementation KeywordAlgorithm

-(NSDictionary *)keywordAlgorithm:(NSString *)keywordText
{
    
    //NSString *newKeywordText = [keywordText stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    
    NSArray *keywordArray =[keywordText componentsSeparatedByString:@"\n"];
    
    NSString *lastKey = nil;
    NSMutableDictionary *frameDictionary = [[NSMutableDictionary alloc]init];
    NSMutableArray *keywordsArrayForKey = [[NSMutableArray alloc]init];
    
    for(NSString *keys in keywordArray){
        NSString *tempKey = [[keys componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
        
        if([tempKey hasPrefix:@"<iframe"]){
            if(lastKey){
                [frameDictionary setObject:keywordsArrayForKey forKey:lastKey];
            }
            keywordsArrayForKey = [[NSMutableArray alloc]init];
            lastKey = [self getFrameSource:tempKey];
        }else{
            if(![tempKey isEqualToString:@""])
                [keywordsArrayForKey addObject:tempKey];
        }
    }
    
    if(lastKey){
        [frameDictionary setObject:keywordsArrayForKey forKey:lastKey];
    }
    return frameDictionary;
}

-(NSString *)getFrameSource:(NSString *)html{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<iframesrc=\"(.*?)\")+?"
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
    NSUserDefaults* keywordValueSet = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dataSet = [[NSMutableDictionary alloc]initWithDictionary:[keywordValueSet objectForKey:@"data"]];
    
    if (dataSet.count == 0) {
        for (NSString* keyword in keywords) {
            [dataSet setObject:[NSNumber numberWithInt:1] forKey:keyword];
        }
    }
    else{
        for (NSString*keyword in keywords) {
            for (NSString*data in [dataSet allKeys]) {
                //NSLog(@"%@",[dataSet allKeys]);
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
    [keywordValueSet setObject:dataSet forKey:@"data"];
    [keywordValueSet synchronize];
    NSLog(@"%@",dataSet);
}


-(void)videoRanking
{
    // Add all the values of the keywords in each video
    NSUserDefaults* keywordValueSet = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dataSet = (NSMutableDictionary *)[keywordValueSet objectForKey:@"data"];
    NSMutableDictionary* finalDataArrangement = [[NSMutableDictionary alloc]init];
    
    NSArray *keyArray = [srcDictionary allKeys];
    
    for (NSString* key in keyArray) {
        NSNumber *calcResult = [[NSNumber alloc]initWithInt:[self getScoreFromKey:[srcDictionary objectForKey:key] withKeyArray:dataSet]];
        [finalDataArrangement setObject:calcResult forKey:key];
    }
    
    [self sortDictionaryWithObjects:finalDataArrangement];
}

-(void)sortDictionaryWithObjects:(NSMutableDictionary *)dictionary{
    NSMutableArray *dictionaryKeys = [[dictionary allKeys] mutableCopy];
    
    int length = (int)[dictionaryKeys count];
    for (int i = length - 1; i>=0; i--) {
        bool toSwitch = false;
        int currIndex = i;
        int minValue = [[dictionary objectForKey:[dictionaryKeys objectAtIndex:i]] intValue];
        
        for (int j = i - 1; j >= 0; j--) {
            int currValue = [[dictionary objectForKey:[dictionaryKeys objectAtIndex:j]] intValue];
            if(currValue < minValue){
                currIndex = j;
                minValue = currValue;
                toSwitch = true;
            }
        }
        if(toSwitch){
            NSString *origObj = [dictionaryKeys objectAtIndex:i];
            NSString *indexObj = [dictionaryKeys objectAtIndex:currIndex];
            [dictionaryKeys setObject:origObj atIndexedSubscript:currIndex];
            [dictionaryKeys setObject:indexObj atIndexedSubscript:i];
        }
    }
    
    videoArray = dictionaryKeys;
    //[videoTableView reloadData];
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



@end
