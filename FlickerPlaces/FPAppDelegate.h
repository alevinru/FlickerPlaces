//
//  FPAppDelegate.h
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPCache.h"
#import "CachedDataDelegate.h"

@interface FPAppDelegate : UIResponder <UIApplicationDelegate, CachedDataDelegate>

    @property (strong, nonatomic) UIWindow *window;
    
    - (NSData*) dataWithContentsOfURL: (NSURL*) url;

    @property (strong, nonatomic) FPCache *imageCache;

@end
