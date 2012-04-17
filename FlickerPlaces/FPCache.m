//
//  FPCache.m
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FPCache.h"

@interface FPCache()

@end

@implementation FPCache

static NSArray * _cacheFiles;
static NSURL * _imagesLocation;


+ (void) initCaches {
    
    NSFileManager * filer = [NSFileManager defaultManager];
    
    NSURL * url =  [filer URLForDirectory: NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL: nil create:YES error:nil];
    
    _imagesLocation = [url URLByAppendingPathComponent:@"images" isDirectory:YES];
    
    BOOL isCreated = [filer createDirectoryAtURL: _imagesLocation withIntermediateDirectories:NO attributes: nil error:nil];
    
    NSLog(@"%@: %@ (created: %@)", NSStringFromSelector(_cmd), url, isCreated ? @"yes" : @"no");
    
}

+ (NSArray *) cacheFiles {
    
    return _cacheFiles;
    
}


+ (NSData*) dataWithContentsOfURL:(NSURL *)url {
    
    NSURL * path = [_imagesLocation URLByAppendingPathComponent: url.lastPathComponent];
    
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), url);
    
    NSData * result = [NSData dataWithContentsOfURL: path];
    
    if (!result) {
        result = [NSData dataWithContentsOfURL: url];
        BOOL wroteFile = [result writeToURL: path atomically: YES];
        NSLog(@"%@: cached file: %@", NSStringFromSelector(_cmd), wroteFile ? @"yes" : @"no");
    }
         
    return result;
    
}

@end
