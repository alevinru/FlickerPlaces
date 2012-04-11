//
//  FPPlaceDetailsViewController.h
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPPlaceDetailsViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *titleCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *countCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *switchCell;

@property (weak, nonatomic) IBOutlet UIStepper *countStepper;

@property (weak, nonatomic) IBOutlet UITextField *countTextField;

@property (strong, nonatomic) NSDictionary * datasource;

- (IBAction)countChange:(UIStepper*)sender;

@end
