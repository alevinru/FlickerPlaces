//
//  FPTopPlacesController.h
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOP_PLACES_VIEW_TITLE @"Top Places"
#define RECENT_PHOTOS_VIEW_TITLE @"Recent Photos"


@interface FPTableViewController : UITableViewController

@property (strong, nonatomic) NSArray * flickrData;

@property (strong, nonatomic) NSDictionary * flickrPlace;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender;

@end
