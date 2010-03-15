//
//  MedialibAlbumBrowserController.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <xmmsclient/xmmsclient.h>
#import "XMMSCollection.h"
#import "StringListDataSource.h"

@interface MedialibAlbumBrowserController : UITableViewController {
	NSString *_artist;
	XMMSCollection *_coll;
	StringListDataSource *_ds;
}

@property (nonatomic, retain) StringListDataSource *dataSource;

-(id)initWithArtist:(NSString *)artist;

@end
