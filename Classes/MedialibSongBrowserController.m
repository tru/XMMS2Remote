//
//  MedialibSongBrowserController.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "MedialibSongBrowserController.h"
#import "IDListDataSource.h"
#import "XMMSClient.h"

@implementation MedialibSongBrowserController

-(id)initWithCollection:(XMMSCollection *)collection
{
	self = [super init];
	if (self) {
		char *albumtitle;
		_coll = collection;
		[_coll retain];
		
		xmmsv_coll_attribute_get(_coll.collection, "value", &albumtitle);
		self.title = [NSString stringWithUTF8String:albumtitle];
		
		self.toolbarItems = [NSArray arrayWithObjects:
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
							 [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add to playlist", nil) style:UIBarButtonItemStyleDone target:self action:@selector(addToPlaylist)] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
							 nil];

	}
	return self;
}

-(void)addToPlaylist
{
	xmmsc_playlist_add_collection([XMMSClient client].xmmsConnection, NULL, _coll.collection, [XMMSClient client].defaultOrder);
	[self dismissModalViewControllerAnimated:YES];
}

-(void)loadView
{
	[super loadView];
	
	IDListDataSource *ds = [[IDListDataSource alloc] initWithCollection:_coll];
	ds.tableView = self.tableView;
	self.tableView.dataSource = ds;
}

-(void)dealloc
{
	[_coll release];
	[super dealloc];
}

@end
