//
//  FPTopPlacesController.m
//  FlickerPlaces
//
//  Created by Levin Alexander on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FPTableViewController.h"
#import "FlickrFetcher.h"
#import "FPPlaceDetailsViewController.h"

#import "ImageViewController.h"

#define TOP_PLACES_VIEW_TITLE @"Top Places"
#define RECENT_PHOTOS_VIEW_TITLE @"Recent Photos"

@interface FPTableViewController ()

@end

@implementation FPTableViewController

@synthesize flickrData = _flickrData;
@synthesize refreshButton = _refreshButton;

- (NSArray *) flickrData {
    return _flickrData ? _flickrData : (_flickrData = [[NSArray alloc] init]);
}

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)sender {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    [spinner startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        [self loadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.navigationItem.rightBarButtonItem = sender;
        });
    });
    
    dispatch_release(downloadQueue);    
}

- (void) loadData {
    if ([self.title isEqualToString: TOP_PLACES_VIEW_TITLE])
        self.flickrData = [FlickrFetcher topPlaces];
    else if ([self.title isEqualToString: RECENT_PHOTOS_VIEW_TITLE])
        self.flickrData = [FlickrFetcher recentGeoreferencedPhotos];

}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSDictionary * fclickrObject = [[self.flickrData objectAtIndex: [self.tableView indexPathForCell: sender].row] copy];
    
    id dvc = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString: @"Show place detail"])
        [dvc setDatasource: fclickrObject];
    else if ([segue.identifier isEqualToString: @"Show photos from the place"])
        [dvc setFlickrData: [FlickrFetcher photosInPlace: fclickrObject maxResults: 20]];
    else if ([segue.identifier isEqualToString: @"Show the photo"])
        [dvc setImageURL: [FlickrFetcher urlForPhoto: fclickrObject format: FlickrPhotoFormatLarge]];
    
    //NSLog(@"%@: %@", NSStringFromSelector(_cmd), segue.identifier);
    
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
     
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setRefreshButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self flickrData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = self.title;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        NSLog(@"No cell for %@", cellIdentifier);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    if ([cellIdentifier isEqualToString: TOP_PLACES_VIEW_TITLE]) {
        cell.textLabel.text = [[self.flickrData objectAtIndex: indexPath.row] objectForKey: FLICKR_PLACE_NAME];
        
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ photos", [[self.flickrData objectAtIndex: indexPath.row] objectForKey: FLICKR_PLACE_PHOTO_COUNT]];
    } else {
        cell.textLabel.text = [[self.flickrData objectAtIndex: indexPath.row] objectForKey: FLICKR_PHOTO_TITLE];
        
        if ([cell.textLabel.text isEqualToString:@""])
            cell.textLabel.text = @"Untitled";
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@",[[self.flickrData objectAtIndex: indexPath.row] objectForKey: FLICKR_PHOTO_OWNER]];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    if ([self.title isEqualToString: TOP_PLACES_VIEW_TITLE]) {
        [self performSegueWithIdentifier: @"Show place detail"  sender: [self.tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
