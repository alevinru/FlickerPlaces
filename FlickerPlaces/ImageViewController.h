//
//  ImageViewController.h
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CachedDataDelegate.h"

@interface ImageViewController : UIViewController <UIScrollViewDelegate>

    @property (nonatomic, strong) NSURL *imageURL;

    @property (weak, nonatomic) IBOutlet UIScrollView *scrollImageView;

    @property (weak, nonatomic) id <CachedDataDelegate> imageSource;

@end
