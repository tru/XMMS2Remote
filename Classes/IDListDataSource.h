//
//  IDListDataSource.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <xmmsclient/xmmsclient.h>
#import "PlaylistViewDataSource.h"
#import "XMMSCollection.h"

@interface IDListDataSource : PlaylistViewDataSource {
}

-(id)initWithCollection:(XMMSCollection*)collection;

@end
