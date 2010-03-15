//
//  XMMSCollection.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//


/* Examples:
 
 XMMSCollection *coll = [[XMMSCollection alloc] initWithParent:[XMMSCollection universe] matchField:@"artist" withValue:@"mind.in.a.box"];
 
 
 */

#import "XMMSCollection.h"

@implementation XMMSCollection

@synthesize collection = _collection;

-(id)initUniverse
{
	self = [super init];
	if (self) {
		_collection = xmmsv_coll_universe();
	}
	return self;
}

-(id)initWithParent:(XMMSCollection*)parent matchField:(NSString*)field withValue:(NSString*)value
{
	self = [super init];
	
	if (self) {
		_collection = xmmsv_coll_new(XMMS_COLLECTION_TYPE_MATCH);
		xmmsv_coll_attribute_set(_collection, "field", [field UTF8String]);
		xmmsv_coll_attribute_set(_collection, "value", [value UTF8String]);
		xmmsv_coll_add_operand(_collection, parent.collection);
	}
	
	return self;
}

+(id)universe
{
	XMMSCollection *coll = [[XMMSCollection alloc] initUniverse];
	return [coll autorelease];
}

-(void)dealloc
{
	xmmsv_coll_unref(_collection);
	[super dealloc];
}

@end
