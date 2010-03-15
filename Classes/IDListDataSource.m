//
//  IDListDataSource.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "IDListDataSource.h"
#import "XMMSClient.h"


@implementation IDListDataSource

static int query_ids (xmmsv_t *value, void *udata)
{
	IDListDataSource *ds = udata;
	id list = [XMMSClient objectWithXMMSV:value];
	
	if ([list isKindOfClass:[NSDictionary class]]) {
		NSLog(@"We have a dict!");
	} else if ([list isKindOfClass:[NSError class]]) {
		NSLog(@"Error when getting list! %@", [list description]);
	} else {
		ds.playlist = [list mutableCopy];
		[ds.tableView reloadData];
	}
	return YES;
}

-(id)initWithCollection:(XMMSCollection*)collection
{
	self = [super init];
	if (self) {
		xmmsv_t *order = xmmsv_new_list();
		
		xmmsv_list_append(order, xmmsv_new_string("tracknr"));
		xmmsv_list_append(order, xmmsv_new_string("title"));
		
		xmmsc_result_t *res = xmmsc_coll_query_ids([XMMSClient client].xmmsConnection,
												   collection.collection,
												   order,
												   0,
												   0);
		
		xmmsc_result_notifier_set(res, query_ids, self);
	}
	return self;
}

@end
