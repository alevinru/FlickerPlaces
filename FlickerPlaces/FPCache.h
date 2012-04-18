//
//  FPCache.h
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPCache : NSObject

    - (NSData*) dataWithContentsOfURL: (NSURL*) url;

    - (id) init;

    - (NSArray *) getCacheFiles;

@end
