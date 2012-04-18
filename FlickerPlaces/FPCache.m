//
//  FPCache.m
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FPCache.h"
#define MAX_CACHE_SIZE 3000000

@interface FPCache()

@end

@implementation FPCache

static NSMutableArray * _cacheFiles;
static NSURL * _imagesLocation;
static uint _sizeTotal;


+ (void) initCaches {
    
    NSFileManager * filer = [NSFileManager defaultManager];
    
    NSURL * url =  [filer URLForDirectory: NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL: nil create:YES error:nil];
    
    _cacheFiles = [[NSMutableArray alloc] init];
    _imagesLocation = [url URLByAppendingPathComponent:@"images" isDirectory:YES];
    _sizeTotal = 0;
    
    BOOL isCreated = [filer createDirectoryAtURL: _imagesLocation withIntermediateDirectories:NO attributes: nil error:nil];
    
    NSLog(@"%@: %@ (created: %@)", NSStringFromSelector(_cmd), url, isCreated ? @"yes" : @"no");
    
    NSArray * keys = [NSArray arrayWithObjects: NSURLCreationDateKey, NSURLFileSizeKey, nil];
    
    NSArray * images = [filer contentsOfDirectoryAtURL: _imagesLocation includingPropertiesForKeys: keys options:NSDirectoryEnumerationSkipsHiddenFiles error: nil];
    
    NSNumber * size;        
    NSDate * date;
    
    for (NSURL * image in images) {
        
        BOOL isSized = [image getResourceValue: &size forKey:NSURLFileSizeKey error:nil];
        
        BOOL whenCreated = [image getResourceValue: &date forKey: NSURLCreationDateKey error:nil];

        NSLog(@"%@: image found: %@ of %d bytes at %@ (%d %d)", NSStringFromSelector(_cmd), image, [size intValue], date, isSized, whenCreated );
        
        _sizeTotal += [size intValue];
        
        [_cacheFiles addObject: [NSDictionary dictionaryWithObjectsAndKeys: [image lastPathComponent], @"name", size , @"size", date, @"lastAccess", nil]];
        
    }
    
    [_cacheFiles sortUsingComparator: ^(id obj1, id obj2) {
        NSDate * d1 = [obj1 objectForKey: @"lastAccess"];
        NSDate * d2 = [obj2 objectForKey: @"lastAccess"];
        
        return [d1 compare: d2];
    }];
    
    for (NSDictionary * image in _cacheFiles) {
        NSLog(@"%@: image (size, ts): %@ (%d, %@)", NSStringFromSelector(_cmd), [image objectForKey: @"name"], [[image objectForKey: @"size"] intValue], [image objectForKey: @"lastAccess"]);
    }
    
    
    NSLog(@"%@: images found total: %d bytes", NSStringFromSelector(_cmd), _sizeTotal);
    
}

+ (void) registerCachedObject: (NSString *) name ofSize: (NSNumber*) bytes {
    [_cacheFiles addObject: [NSDictionary dictionaryWithObjectsAndKeys: name, @"name", bytes, @"size", [NSDate dateWithTimeIntervalSinceNow: 0], @"lastAccess", nil]];
    _sizeTotal += [bytes intValue];
    NSLog(@"%@ total cache size: %d", NSStringFromSelector(_cmd), _sizeTotal);
}


+ (BOOL) resizeCacheToFreeSpaceOf: (NSNumber*) bytes {
    
    uint freedBytes = 0;
    
    while ([bytes intValue] + _sizeTotal > MAX_CACHE_SIZE ) {
        
        NSDictionary * objectToEvict = [_cacheFiles objectAtIndex:0];
        NSNumber * size = [objectToEvict objectForKey: @"size"];
        NSString * name = [objectToEvict objectForKey: @"name"];
        
        if (!size) return NO;
        
        freedBytes += [size intValue];
        
        NSLog(@"%@ removes: %@", NSStringFromSelector(_cmd), name);
        
        [_cacheFiles removeObjectAtIndex: 0];
        
        _sizeTotal -= [size intValue];
        
        [[NSFileManager defaultManager] removeItemAtURL: [_imagesLocation URLByAppendingPathComponent: name isDirectory:NO] error: nil];
        
    }
    
    NSLog(@"%@ total cache size: %d", NSStringFromSelector(_cmd), _sizeTotal);
    
    return YES;

}

+ (NSArray *) cacheFiles {
    
    return _cacheFiles;
    
}


+ (NSData*) dataWithContentsOfURL:(NSURL *)url {
    
    NSURL * path = [_imagesLocation URLByAppendingPathComponent: url.lastPathComponent];
    
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), url);
    
    NSData * result = [NSData dataWithContentsOfURL: path];
    
    if (result) {
        
        NSUInteger cachedIndex = [_cacheFiles indexOfObjectPassingTest: ^(NSDictionary *item, NSUInteger idx, BOOL * stop) { return [[item objectForKey: @"name"] isEqualToString: url.lastPathComponent]; }
         ];
        
        NSDictionary * obj = [_cacheFiles objectAtIndex: cachedIndex];
        
        [_cacheFiles removeObjectAtIndex: cachedIndex];
        [_cacheFiles addObject: obj];
        
    } else {
        
        result = [NSData dataWithContentsOfURL: url];
        
        NSNumber * size = [NSNumber numberWithInt: result.length];
        
        if (_sizeTotal + [size intValue] > MAX_CACHE_SIZE)
            [self resizeCacheToFreeSpaceOf: size];
        
        BOOL wroteFile = [result writeToURL: path atomically: YES];
        
        if (wroteFile) [self registerCachedObject: path.lastPathComponent ofSize: size];
        
        NSLog(@"%@: cached file: %@", NSStringFromSelector(_cmd), wroteFile ? @"yes" : @"no");
        
    }
    
    return result;
    
}

@end
