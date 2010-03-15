//
//  MedialibSongBrowserController.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <xmmsclient/xmmsclient.h>

#import "XMMSCollection.h"

@interface MedialibSongBrowserController : UITableViewController {
	XMMSCollection *_coll;
}

-(id)initWithCollection:(XMMSCollection*)collection;
@end
