//
//  PlaylistViewController.m
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-02.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import "PlaylistViewController.h"
#import "PlaylistViewDataSource.h"
#import "NowPlayingController.h"
#import "MedialibBrowserController.h"
#import "XMMSClient.h"
#import "PlaylistCell.h"

@implementation PlaylistViewController

@synthesize playlistName = _playlistName;
@synthesize ds = _ds;

static int playlist_list_entries (xmmsv_t *value, void *udata)
{
	NSLog(@"CB: playlist_list_entries");
	PlaylistViewController *vc = udata;
	
	id plist = [XMMSClient objectWithXMMSV:value];
	if ([plist isKindOfClass:[NSError class]]) {
		NSLog(@"Error when converting XMMSV!");
	}
	
	if ([plist count] < 1) {
		return YES;
	}
	
	vc.ds.playlist = [plist mutableCopy];
	
	NSMutableArray *rows = [NSMutableArray new];
	for (int i = 0; i < [vc.ds.playlist count]; i ++) {
		[rows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
	}
	
	[vc.tableView beginUpdates];
	[vc.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationBottom];
	[vc.tableView endUpdates];
	
	[rows release];

	return YES;
}


static int playlist_changed (xmmsv_t *value, void *udata)
{
	NSLog(@"CB: playlist_changed");
	PlaylistViewController *viewCtrl = udata;
	PlaylistViewDataSource *ds = viewCtrl.ds;
	
	NSDictionary *d = [XMMSClient objectWithXMMSV:value];
	
	NSNumber *medialibID=nil;
	NSUInteger playlistPosition=0;
	NSString *playlistName=nil;
	
	id tmp = [d objectForKey:@"id"];
	if (tmp) {
		medialibID = [NSNumber numberWithInt:[tmp intValue]];
	}
	
	tmp = [d objectForKey:@"position"];
	if (tmp) {
		playlistPosition = [tmp intValue];
	}
	
	tmp = [d objectForKey:@"name"];
	if (tmp) {
		playlistName = tmp;
	}
	
	xmms_playlist_changed_actions_t changedAction = [[d objectForKey:@"type"] intValue];
	NSLog(@"Type of change = %d", changedAction);
	
	NSMutableArray *rowsAdd = [NSMutableArray new];
	NSMutableArray *rowsRemove = [NSMutableArray new];
	
	switch (changedAction) {
		case XMMS_PLAYLIST_CHANGED_ADD:
			[ds.playlist addObject:medialibID];
			[rowsAdd addObject:[NSIndexPath indexPathForRow:[ds.playlist count]-1 inSection:0]];
			break;

		case XMMS_PLAYLIST_CHANGED_INSERT:
			[ds.playlist insertObject:medialibID atIndex:playlistPosition];
			[rowsAdd addObject:[NSIndexPath indexPathForRow:playlistPosition inSection:0]];
			break;

		case XMMS_PLAYLIST_CHANGED_REMOVE:
			[ds.playlist removeObjectAtIndex:playlistPosition];
			[rowsRemove addObject:[NSIndexPath indexPathForRow:playlistPosition inSection:0]];
			break;

		case XMMS_PLAYLIST_CHANGED_MOVE:
		{
			NSUInteger newpos = [[d objectForKey:@"newposition"] intValue];
			
			NSLog(@"moving from %d to %d", playlistPosition, newpos);
			
			NSNumber *oldentry = [ds.playlist objectAtIndex:playlistPosition];
			[oldentry retain];
			[ds.playlist removeObjectAtIndex:playlistPosition];
			[ds.playlist insertObject:oldentry atIndex:newpos];
			[oldentry release];
			
			break;
		}

		case XMMS_PLAYLIST_CHANGED_SORT:
		case XMMS_PLAYLIST_CHANGED_CLEAR:
		case XMMS_PLAYLIST_CHANGED_SHUFFLE:
		{
			
			for (int i = 0; i < [ds.playlist count]; i ++) {
				[rowsRemove addObject:[NSIndexPath indexPathForRow:i inSection:0]];
			}
			
			[ds.playlist removeAllObjects];
			
			if (changedAction == XMMS_PLAYLIST_CHANGED_SORT || changedAction == XMMS_PLAYLIST_CHANGED_SHUFFLE) {
				xmmsc_result_t *res = xmmsc_playlist_list_entries([XMMSClient client].xmmsConnection, NULL);
				xmmsc_result_notifier_set(res, playlist_list_entries, viewCtrl);
			}
			
			break;
		}
		
		case XMMS_PLAYLIST_CHANGED_UPDATE:
			NSLog(@"Playlist changed Update?");
			return YES;

		default:
			NSLog(@"Warning: strange playlist changed action today?");
			return YES;
	}
	
	if ([rowsRemove count] > 0) {
		NSLog(@"Removing %d entries", [rowsRemove count]);
		[viewCtrl.tableView beginUpdates];
		[viewCtrl.tableView deleteRowsAtIndexPaths:rowsRemove withRowAnimation:UITableViewRowAnimationBottom];
		[viewCtrl.tableView endUpdates];
	}
	
	if ([rowsAdd count] > 0) {
		[viewCtrl.tableView beginUpdates];
		[viewCtrl.tableView insertRowsAtIndexPaths:rowsAdd withRowAnimation:UITableViewRowAnimationTop];
		[viewCtrl.tableView endUpdates];
	}
	
	[rowsAdd release];
	[rowsRemove release];
	
	return YES;
}

-(id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) {
		
		self.title = NSLocalizedString(@"Playlist", nil);
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				target:self
																				 action:@selector(addEntries)] autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Now playing", nil)
																				   style:UIBarButtonItemStyleDone
																				  target:self
																				  action:@selector(nowPlaying)] autorelease];

		
		self.toolbarItems = [NSArray arrayWithObjects:
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																			target:self
																			action:@selector(actionEntries)] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil
																			action:nil] autorelease],							 
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																			target:self
																			action:@selector(editEntries)] autorelease],
							 
							 nil];
		
		self.playlistName = nil;
		self.ds = [PlaylistViewDataSource new];

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(notificationStatus:) 
													 name:XMMSClientNotificationPlaybackStatus
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(notificationCurrentPos:)
													name:XMMSClientNotificationPlaylistPosition
												   object:nil];
		
		
		XMMSClient *client = [XMMSClient client];
		xmmsc_result_t *res = xmmsc_broadcast_playlist_changed(client.xmmsConnection);
		xmmsc_result_notifier_set(res, playlist_changed, self);
		
		res = xmmsc_playlist_list_entries(client.xmmsConnection, NULL);
		xmmsc_result_notifier_set(res, playlist_list_entries, self);
							 
	}
	return self;
}

-(void)notificationCurrentPos:(id)data
{
	NSUInteger newPosition = [[[data userInfo] objectForKey:@"position"] intValue];
	if (_position == newPosition) {
		return;
	}
	
	PlaylistCell *cell = (PlaylistCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_position inSection:0]];
	if (cell) {
		cell.currentItem = NO;
	}

	cell = (PlaylistCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:newPosition inSection:0]];
	if (cell) {
		cell.currentItem = YES;
	}
	
	_position = newPosition;
}

-(void)notificationStatus:(id)data
{
	_currentStatus = [[[data userInfo] objectForKey:@"status"] intValue];
}

-(void)editEntries
{
	if (self.tableView.editing) {
		[self.tableView setEditing:NO animated:YES];
	} else {
		[self.tableView setEditing:YES animated:YES];
	}
}

-(void)actionEntries
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Playlist actions", nil)
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										  destructiveButtonTitle:NSLocalizedString(@"Clear", nil)
											   otherButtonTitles:NSLocalizedString(@"Shuffle", nil), NSLocalizedString(@"Switch", nil), nil];
	[action showInView:self.view];
}

-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0: /* clear playlist */
			xmmsc_playlist_clear([XMMSClient client].xmmsConnection, [_playlistName UTF8String]);
			break;
		case 1: /* shuffle the playlist */
			xmmsc_playlist_shuffle([XMMSClient client].xmmsConnection, [_playlistName UTF8String]);
			break;
		case 2: /* switch playlist */
			/* TODO */
			break;
		default:
			break;
	}
}

-(void)nowPlaying
{
	NowPlayingController *playingCtrl = [[NowPlayingController alloc] init];
	[self.navigationController pushViewController:playingCtrl animated:YES];
	[playingCtrl release];
}

-(void)addEntries
{
	MedialibBrowserController *medialibCtrl = [[MedialibBrowserController alloc] init];
	UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:medialibCtrl];
	
	[self.navigationController presentModalViewController:navCtrl animated:YES];
	[medialibCtrl release];
	[navCtrl release];
}

-(void)viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	self.navigationController.navigationBar.translucent = NO;
	
	[self.navigationController setToolbarHidden:NO animated:NO];
}

-(void)viewDidLoad
{
	self.tableView.dataSource = self.ds;
	self.tableView.delegate = self;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	xmmsc_result_unref(xmmsc_playlist_set_next([XMMSClient client].xmmsConnection, [indexPath indexAtPosition:1]));
	xmmsc_result_unref(xmmsc_playback_tickle([XMMSClient client].xmmsConnection));
	
	if (_currentStatus == XMMS_PLAYBACK_STATUS_STOP || _currentStatus == XMMS_PLAYBACK_STATUS_PAUSE) {
		xmmsc_result_unref(xmmsc_playback_start([XMMSClient client].xmmsConnection));
	}
}


@end
