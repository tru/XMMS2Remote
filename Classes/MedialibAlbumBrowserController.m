//
//  MedialibAlbumBrowserController.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "MedialibAlbumBrowserController.h"
#import "MedialibSongBrowserController.h"
#import "XMMSClient.h"

@implementation MedialibAlbumBrowserController

@synthesize dataSource = _ds;

static int query_info (xmmsv_t *value, void *udata)
{
	MedialibAlbumBrowserController *ctrl = udata;
	NSArray *list = [XMMSClient objectWithXMMSV:value];
	NSMutableArray *changed = [NSMutableArray new];
	int i = 0;
	for (NSDictionary *dict in list) {
		NSString *album = [dict objectForKey:@"album"];
		if (!album) {
			album = NSLocalizedString(@"Unknown album", nil);
		}
		[ctrl.dataSource.dataList addObject:album];
		[changed addObject:[NSIndexPath indexPathForRow:i++ inSection:0]];
	}
	
	[ctrl.tableView beginUpdates];
	[ctrl.tableView insertRowsAtIndexPaths:changed withRowAnimation:UITableViewRowAnimationFade];
	[ctrl.tableView endUpdates];
	[changed release];
	
	return YES;
}

-(id)initWithArtist:(NSString*)artist
{
	self = [super init];
	
	if (self) {
		self.title = artist;
		_artist = artist;
		

		self.toolbarItems = [NSArray arrayWithObjects:
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
							 [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add to playlist", nil) style:UIBarButtonItemStyleDone target:self action:@selector(addToPlaylist)] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
							 nil];
		
		_ds = [StringListDataSource new];
		_coll = [[XMMSCollection alloc] initWithParent:[XMMSCollection universe] matchField:@"artist" withValue:artist];
		
		xmmsv_t *album = xmmsv_new_list();
		xmmsv_list_append(album, xmmsv_new_string("album"));
		
		xmmsc_result_t *res = xmmsc_coll_query_infos([XMMSClient client].xmmsConnection,
													 _coll.collection,
													 album,
													 0,
													 0,
													 album,
													 album);
		xmmsc_result_notifier_set(res, query_info, self);
		xmmsc_result_unref(res);
		xmmsv_unref(album);
		
	}
	
	return self;
}

-(void)addToPlaylist
{
	xmmsc_playlist_add_collection([XMMSClient client].xmmsConnection, nil, _coll.collection, [XMMSClient client].defaultOrder);
	[self dismissModalViewControllerAnimated:YES];
}

-(void)loadView
{
	[super loadView];
	self.tableView.dataSource = _ds;
	self.tableView.delegate = self;
	[self.navigationController setToolbarHidden:NO animated: YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *albumstr = [_ds stringForRow:indexPath];
	NSLog(@"album = %@", albumstr);
	
	XMMSCollection *album = [[XMMSCollection alloc] initWithParent:_coll matchField:@"album" withValue:albumstr];
	MedialibSongBrowserController *songCtrl = [[MedialibSongBrowserController alloc] initWithCollection:album];
	[album release];
	
	[self.navigationController pushViewController:songCtrl animated:YES];
	
	[songCtrl release];
}

-(void)dealloc
{
	if (_coll) {
		[_coll release];
	}
	[super dealloc];
}

@end
