//
//  PlaylistViewController.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-02.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistViewDataSource.h"
#import <xmmsclient/xmmsclient.h>

@interface PlaylistViewController : UITableViewController<UITableViewDelegate,UIActionSheetDelegate>
{
	PlaylistViewDataSource *_ds;
    NSString *_playlistName;
	xmms_playback_status_t _currentStatus;
	NSUInteger _position;
}

@property (nonatomic,retain) NSString *playlistName;
@property (nonatomic,retain) PlaylistViewDataSource *ds;

@end
