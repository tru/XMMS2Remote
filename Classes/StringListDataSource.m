//
//  StringListDataSource.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-10.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "StringListDataSource.h"


@implementation StringListDataSource
@synthesize dataList = _dataList;

-(id)init
{
	self = [super init];
	if (self) {
		_dataList = [NSMutableArray new];
	}
	return self;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int pos = [indexPath indexAtPosition:1];
	
	NSString *ident = [self.dataList objectAtIndex:pos];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident] autorelease];
		cell.textLabel.text = ident;
	}
	
	return cell;
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return [_dataList count];
	} else {
		return 0;
	}
}

-(NSString*)stringForRow:(NSIndexPath*)indexPath
{
	return [_dataList objectAtIndex:[indexPath indexAtPosition:1]];
}

@end
