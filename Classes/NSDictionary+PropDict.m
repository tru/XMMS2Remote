//
//  NSDictionary+PropDict.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-03.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "NSDictionary+PropDict.h"
#import "XMMSClient.h"


@implementation NSDictionary (PropDict)

-(id)propertyObjectForKey:(NSString*)key andSources:(NSArray *)sources
{
	NSDictionary *kv = [self objectForKey:key];
	if (!kv) {
		return nil;
	}
	
	for (NSString *source in sources) {
		id value = [kv objectForKey:source];
		
		if (value) {
			return value;
		}
		
		if ([source hasSuffix:@"*"]) {
			for (NSString *kvsrc in [kv allKeys]) {
				if ([kvsrc hasPrefix:[source substringToIndex:[source length]-1]]) {
					return [kv objectForKey:kvsrc];
				}
			}
		}
	}
	
	return nil;
}

-(id)propertyObjectForKey:(NSString *)key
{
	XMMSClient *client = [XMMSClient client];
	NSMutableArray *sources = client.defaultSources;
	return [self propertyObjectForKey:key andSources:sources];													 
}



@end
