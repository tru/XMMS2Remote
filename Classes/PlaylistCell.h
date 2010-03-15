//
//  PlaylistCell.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-03.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlaylistCell : UITableViewCell {
	NSDictionary *_properties;
	NSUInteger _position;
	BOOL _currentItem;
}

-(id)initWithMID:(NSUInteger)mid andPosition:(NSUInteger)position;

@property (nonatomic, retain) NSDictionary *properties;
@property (nonatomic, assign) BOOL currentItem;

@end
