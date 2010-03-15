//
//  ServerBrowserController.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ServerBrowserController : UITableViewController<UITableViewDataSource, UITableViewDelegate> {
	UIImageView *_logoView;
	NSMutableArray *_servers;
}

@end
