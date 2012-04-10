//
//  FlickerPlacesTests.m
//  FlickerPlacesTests
//
//  Created by Levin Alexander on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickerPlacesTests.h"
#import "FlickrFetcher.h"

@implementation FlickerPlacesTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testTopPlaces
{
    NSArray * topPlaces = [FlickrFetcher topPlaces];
    
    NSLog(@"%@ count is %d", NSStringFromSelector(_cmd), [topPlaces count]);
    STAssertTrue([topPlaces count], @"TopPlaces success");
    
}

- (void)testRecentPhotos
{
    NSArray * recentPhotos = [FlickrFetcher recentGeoreferencedPhotos];
    
    NSLog(@"%@ count is %d", NSStringFromSelector(_cmd), [recentPhotos count]);
    STAssertTrue([recentPhotos count], @"RecentPhotos success");
    
}

@end
