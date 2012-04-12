//
//  FPTopPlacesController.h
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPTableViewController : UITableViewController

@property (strong, nonatomic) NSArray * flickrData; 

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender;

@end
