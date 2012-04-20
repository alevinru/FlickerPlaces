//
//  FPCache.m
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FPCache.h"
#define MAX_CACHE_SIZE 10000000

@interface FPCache()

@property (strong) NSMutableArray * cacheFiles;
@property (strong) NSURL * imagesLocation;
@property NSUInteger totalSize;
@end

@implementation FPCache

@synthesize cacheFiles = _cacheFiles;
@synthesize imagesLocation = _imagesLocation;
@synthesize totalSize = _totalSize;


- (NSArray *) getCacheFiles {
    return [self.cacheFiles copy];
}


- (id) init {
    
    self = [super init];
    
    NSFileManager * filer = [NSFileManager defaultManager];
    
    NSURL * url =  [filer URLForDirectory: NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL: nil create:YES error:nil];
    
    self.cacheFiles = [[NSMutableArray alloc] init];
    self.imagesLocation = [url URLByAppendingPathComponent: @"images" isDirectory:YES];
    self.totalSize = 0;
    
    [filer createDirectoryAtURL: self.imagesLocation withIntermediateDirectories:NO attributes: nil error:nil];
    
    NSArray * images = [filer 
                        contentsOfDirectoryAtURL: self.imagesLocation
                      includingPropertiesForKeys: [NSArray arrayWithObjects: NSURLCreationDateKey, NSURLFileSizeKey, nil]
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                           error: nil
    ];
    
    for (NSURL * image in images) {
        
        NSNumber * size;        
        NSDate * date;
        
        [image getResourceValue: &size forKey:NSURLFileSizeKey error:nil];
        [image getResourceValue: &date forKey: NSURLCreationDateKey error:nil];

        self.totalSize += [size intValue];
        
        [self.cacheFiles addObject: [NSDictionary dictionaryWithObjectsAndKeys: [image lastPathComponent], @"name", size , @"size", date, @"lastAccess", nil]];
        
    }
    
    [self.cacheFiles sortUsingComparator: ^(id obj1, id obj2) {
        NSDate * d1 = [obj1 objectForKey: @"lastAccess"];
        NSDate * d2 = [obj2 objectForKey: @"lastAccess"];
        
        return [d1 compare: d2];
    }];
    
    /*for (NSDictionary * image in self.cacheFiles) {
        NSLog(@"%@ image (size, ts): %@ (%d, %@)", NSStringFromSelector(_cmd), [image objectForKey: @"name"], [[image objectForKey: @"size"] intValue], [image objectForKey: @"lastAccess"]);
    }*/
    
    //NSLog(@"%@ images found total size: %d bytes", NSStringFromSelector(_cmd), self.totalSize);
    
    return self;
    
}

- (void) registerCachedObject: (NSString *) name ofSize: (NSNumber*) bytes {

    [self.cacheFiles addObject: [NSDictionary dictionaryWithObjectsAndKeys: name, @"name", bytes, @"size", [NSDate dateWithTimeIntervalSinceNow: 0], @"lastAccess", nil]];
    self.totalSize += [bytes intValue];
    
    //NSLog(@"%@ total cache size: %d", NSStringFromSelector(_cmd), self.totalSize);

}

- (NSUInteger) evictFromCache: (NSUInteger) atIndex {
    
    NSDictionary * objectToEvict = [self.cacheFiles objectAtIndex:atIndex];
    NSNumber * size = [objectToEvict objectForKey: @"size"];
    NSString * name = [objectToEvict objectForKey: @"name"];
    
    //NSLog(@"%@ removes: %@", NSStringFromSelector(_cmd), name);
    
    [self.cacheFiles removeObjectAtIndex: atIndex];
    
    self.totalSize -= [size intValue];
    
    [[NSFileManager defaultManager] removeItemAtURL: [self.imagesLocation URLByAppendingPathComponent: name isDirectory:NO] error: nil];
    
    return [size intValue];
}

- (BOOL) resizeCacheToFreeSpaceOf: (NSNumber*) bytes {
    
    uint freedBytes = 0;
    
    while ([bytes intValue] + self.totalSize > MAX_CACHE_SIZE ) {
        
        NSUInteger size = [self evictFromCache: 0];
        
        if (!size) return NO;
        
        freedBytes += size;
        
    }
    
    //NSLog(@"%@ total cache size: %d", NSStringFromSelector(_cmd), self.totalSize);
    
    return YES;

}


- (NSData*) dataWithContentsOfURL:(NSURL *)url {
    
    NSURL * path = [self.imagesLocation URLByAppendingPathComponent: url.lastPathComponent];
    
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), url);
    
    NSData * result = [NSData dataWithContentsOfURL: path];
    
    if (result) {
        
        NSUInteger cachedIndex = [self.cacheFiles indexOfObjectPassingTest: ^(NSDictionary *item, NSUInteger idx, BOOL * stop) { return [[item objectForKey: @"name"] isEqualToString: url.lastPathComponent]; }
         ];
        
        NSDictionary * obj = [self.cacheFiles objectAtIndex: cachedIndex];
        
        [self.cacheFiles removeObjectAtIndex: cachedIndex];
        [self.cacheFiles addObject: obj];
        
        //NSLog(@"%@ from cache at index: %d", NSStringFromSelector(_cmd), cachedIndex);
        
    } else {
        
        result = [NSData dataWithContentsOfURL: url];
        
        NSNumber * size = [NSNumber numberWithInt: result.length];
        
        [self resizeCacheToFreeSpaceOf: size];
        
        BOOL wroteFile = [result writeToURL: path atomically: YES];
        
        if (wroteFile) [self registerCachedObject: path.lastPathComponent ofSize: size];
        
        //NSLog(@"%@ new file: %@", NSStringFromSelector(_cmd), wroteFile ? @"yes" : @"no");
        
    }
    
    return result;
    
}


@end
