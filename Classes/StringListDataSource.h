//
//  StringListDataSource.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-10.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StringListDataSource : NSObject<UITableViewDataSource> {
	NSMutableArray *_dataList;
}

@property (nonatomic, retain) NSMutableArray *dataList;


-(id)init;
-(NSString*)stringForRow:(NSIndexPath *)indexPath;

@end
