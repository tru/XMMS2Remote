//
//  PlaylistViewDataSource.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-02.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "PlaylistViewDataSource.h"
#import "XMMSClient.h"
#import "NSDictionary+PropDict.h"
#import "PlaylistCell.h"

@implementation PlaylistViewDataSource

@synthesize playlist = _playlist;
@synthesize tableView = _tableView;

#pragma mark XMMSClient callbacks


static int medialib_get_info (xmmsv_t *value, void *udata)
{
	NSLog(@"CB: medialib_get_info");
	PlaylistCell *cell = udata;
	
	NSDictionary *dict = [XMMSClient objectWithXMMSV:value];
	if ([dict isKindOfClass:[NSError class]]) {
		NSLog(@"Error when converting XMMSV!");
		cell.textLabel.text = @"Error!";
		[cell release];
		return NO;
	}
	
	cell.properties = dict;
	
	[cell release];
	return YES;
}

#pragma mark NSObject

-(id)init
{
	self = [super init];
	
	if (self) {
		
		_playlist = [[NSMutableArray alloc] init];
	
	}
	return self;
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger position = [indexPath indexAtPosition:1];
	NSNumber *mid = [_playlist objectAtIndex:position];
	NSString *ident = [NSString stringWithFormat:@"%d@%d", [mid intValue], position];
	
	PlaylistCell *cell = ((PlaylistCell*)[tableView dequeueReusableCellWithIdentifier:ident]);
	if (!cell) {
		cell = [[[PlaylistCell alloc] initWithMID:[mid intValue] andPosition:position] autorelease];
		
		/* This means that we don't have media information, so we need to ask for it */
		xmmsc_result_t *res = xmmsc_medialib_get_info([XMMSClient client].xmmsConnection, [mid intValue]);
		xmmsc_result_notifier_set(res, medialib_get_info, cell);
		[cell retain]; /* the notifier will give this away later */
	}
	
	return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_playlist count];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
	xmmsc_playlist_move_entry([XMMSClient client].xmmsConnection, NULL, [sourceIndexPath indexAtPosition:1], [destinationIndexPath indexAtPosition:1]);
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger pos = [indexPath indexAtPosition:1];
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		xmmsc_playlist_remove_entry([XMMSClient client].xmmsConnection, NULL, pos);
	} else {
		NSLog(@"InsertStyle");
	}
}

@end
