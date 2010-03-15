//
//  PlaylistViewDataSource.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-02.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlaylistViewDataSource : NSObject<UITableViewDataSource> {
	NSMutableArray *_playlist;
	UITableView *_tableView;
}

-(id)init;

@property (nonatomic, assign) NSMutableArray *playlist;
@property (nonatomic, retain) UITableView *tableView;

@end
