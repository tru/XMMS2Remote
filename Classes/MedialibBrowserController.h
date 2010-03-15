//
//  MedialibBrowserController.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-04.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringListDataSource.h"

@interface MedialibBrowserController : UITableViewController {
	StringListDataSource *_ds;
}

@property (nonatomic, retain) StringListDataSource *dataSource;

@end
