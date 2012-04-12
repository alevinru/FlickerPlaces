//
//  ImageViewController.m
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation ImageViewController

@synthesize imageView = _imageView;
@synthesize activityIndicator = _activityIndicator;
@synthesize imageURL = _imageURL;
@synthesize scrollImageView = _scrollImageView;

- (void)loadImage
{
    if (self.imageView) {
        if (self.imageURL) {
            dispatch_queue_t imageDownloadQ = dispatch_queue_create("ShutterbugViewController image downloader", NULL);
            
            [self.activityIndicator startAnimating];
            
            dispatch_async(imageDownloadQ, ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                    self.imageView.image = image;
                    self.scrollImageView.maximumZoomScale = 1.0;
                    self.scrollImageView.contentSize = self.imageView.frame.size;
                    
                    //NSLog(@"%@ image size: %f, %f", NSStringFromSelector(_cmd), image.size.width, image.size.height);
                    //NSLog(@"%@ imageView bounds: %f, %f", NSStringFromSelector(_cmd), self.imageView.bounds.size.width, self.imageView.bounds.size.height);
                    //NSLog(@"%@ scrollView bounds: %f, %f", NSStringFromSelector(_cmd), self.scrollImageView.bounds.size.width, self.scrollImageView.bounds.size.height);
                    
                    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);

                    CGFloat xScale = self.scrollImageView.bounds.size.width / self.imageView.frame.size.width;
                    CGFloat yScale = self.scrollImageView.bounds.size.height / self.imageView.frame.size.height;
                    
                    self.scrollImageView.zoomScale = self.scrollImageView.minimumZoomScale = MAX(yScale, xScale);            
                });
            });
            dispatch_release(imageDownloadQ);
        } else {
            self.imageView.image = nil;
        }
    }
}

- (void)setImageURL:(NSURL *)imageURL
{
    if (![_imageURL isEqual:imageURL]) {
        _imageURL = imageURL;
        if (self.imageView.window) {    // we're on screen, so update the image
            [self loadImage];           
        } else {                        // we're not on screen, so no need to loadImage (it will happen next viewWillAppear:)
            self.imageView.image = nil; // but image has changed (so we can't leave imageView.image the same, so set to nil)
        }
    }
}

/*
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    NSLog(@"%@ imageView scale: %f", NSStringFromSelector(_cmd), scale);
    NSLog(@"%@ imageView frame: %f, %f", NSStringFromSelector(_cmd), self.imageView.frame.size.width, self.imageView.frame.size.height);
    NSLog(@"%@ scrollView contentSize: %f, %f", NSStringFromSelector(_cmd), self.scrollImageView.contentSize.width, self.scrollImageView.contentSize.height);
}
*/

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.imageView.image && self.imageURL) [self loadImage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    [self setImageView: nil];
    [self setActivityIndicator:nil];
    [self setScrollImageView:nil];
    
    [super viewDidUnload];
}

@end
