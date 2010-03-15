//
//  MedialibBrowserController.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-04.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "MedialibBrowserController.h"
#import "StringListDataSource.h"
#import "MedialibAlbumBrowserController.h"
#import "XMMSClient.h"

@implementation MedialibBrowserController

@synthesize dataSource = _ds;

static int query_infos (xmmsv_t *value, void *udata)
{
	MedialibBrowserController *ctrl = udata;
	NSArray *list = [XMMSClient objectWithXMMSV:value];
	NSMutableArray *changed = [NSMutableArray new];
	int i = 0;
	for (NSDictionary *dict in list) {
		NSString *artist = [dict objectForKey:@"artist"];
		if (!artist) {
			artist = NSLocalizedString(@"Unknown artist", nil);
		}
		[ctrl.dataSource.dataList addObject:artist];
		[changed addObject:[NSIndexPath indexPathForRow:i++ inSection:0]];
	}
	
	[ctrl.tableView beginUpdates];
	[ctrl.tableView insertRowsAtIndexPaths:changed withRowAnimation:UITableViewRowAnimationNone];
	[ctrl.tableView endUpdates];
	[changed release];
	
	return YES;
}

-(id)init
{
	self = [super init];
	if (self) {
		self.title = NSLocalizedString(@"Medialib", nil);
		
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																							   target:self
																							   action:@selector(close)] autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
																								target:self
																								action:@selector(search)] autorelease];
		
		
		_ds = [StringListDataSource new];
		
		xmmsv_t *artist = xmmsv_new_list();
		xmmsv_list_append(artist, xmmsv_new_string("artist"));
		
		xmmsc_result_t *res = xmmsc_coll_query_infos([XMMSClient client].xmmsConnection,
													 [XMMSCollection universe].collection,
													 artist,
													 0,
													 0,
													 artist,
													 artist);
		xmmsv_unref(artist);
		xmmsc_result_notifier_set(res, query_infos, self);
		xmmsc_result_unref(res);
		
	}
	return self;
}

-(void)search
{
}

-(void)close
{
	[self dismissModalViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
	[self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)loadView
{
	[super loadView];
	
	self.tableView.dataSource = _ds;
	self.tableView.delegate = self;	
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	StringListDataSource *ds = self.tableView.dataSource;
	MedialibAlbumBrowserController *albumBrowser = [[MedialibAlbumBrowserController alloc] initWithArtist:[ds stringForRow:indexPath]];
	[self.navigationController pushViewController:albumBrowser animated:YES];
	[albumBrowser release];
}

@end
