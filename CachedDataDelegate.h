//
//  CachedDataDelegate.h
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CachedDataDelegate <NSObject>

@required
- (NSData*) dataWithContentsOfURL: (NSURL*) url;

@end
