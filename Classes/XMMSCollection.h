//
//  XMMSCollection.h
//  XMMS2Remote
//
//  Created by Tobias Rundström on 2010-03-08.
//  Copyright 2010 Purple Scout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <xmmsclient/xmmsclient.h>

@interface XMMSCollection : NSObject {
	xmmsv_coll_t *_collection;
}

@property (nonatomic, readonly) xmmsv_coll_t *collection;

-(id)initWithParent:(XMMSCollection *)parent matchField:(NSString *)field withValue:(NSString *)value;
+(XMMSCollection*)universe;

@end
