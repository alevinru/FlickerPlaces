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
#import "FPIdentifiableCell.h"
#import "ImageViewController.h"
#import "FPAppDelegate.h"

@interface FPTableViewController ()

@property (strong, nonatomic) NSMutableDictionary * thumbnails;

@end

@implementation FPTableViewController

@synthesize flickrData = _flickrData;
@synthesize refreshButton = _refreshButton;
@synthesize flickrPlace = _flickrPlace;
@synthesize thumbnails = _thumbnails;

- (NSArray *) flickrData {
    return _flickrData ? _flickrData : (_flickrData = [[NSArray alloc] init]);
}

-(IBAction) editPressed:(UIBarButtonItem *)sender {
    [self.tableView setEditing: !self.tableView.editing];
}

- (IBAction)refreshButtonPressed:(UIBarButtonItem *)theButton {
    
    UIActivityIndicatorView *spinner = [UIActivityIndicatorView alloc];
    
    if (theButton) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[spinner initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite]];
    } else {
        spinner = [spinner initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.frame = self.tableView.frame;
        spinner.color = [UIColor darkGrayColor];
        
        [self.tableView.superview insertSubview: spinner aboveSubview: self.tableView];
    }
    
    [spinner startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    
    dispatch_async(downloadQueue, ^{
        [self loadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if (theButton)
                self.navigationItem.rightBarButtonItem = theButton;
            else {
                [spinner stopAnimating];
                [spinner removeFromSuperview];
            }
        });
    });
    
    dispatch_release(downloadQueue);    
}


- (void) loadData {

    self.thumbnails = [[NSMutableDictionary alloc] init];
    
    if ([self.title isEqualToString: TOP_PLACES_VIEW_TITLE])
        self.flickrData = [FlickrFetcher topPlaces];
    else if ([self.title isEqualToString: RECENT_PHOTOS_VIEW_TITLE])
        self.flickrData = [FlickrFetcher recentGeoreferencedPhotos];
    else if (self.flickrPlace)
        self.flickrData = [FlickrFetcher photosInPlace: self.flickrPlace 
                                            maxResults: 50];
    else if ([self.title isEqualToString: FP_CACHED_PHOTOS]) {
        NSMutableArray * reverseCached = [[NSMutableArray alloc] init];
        for (id obj in [[[(FPAppDelegate*) [UIApplication sharedApplication].delegate imageCache] getCacheFiles] reverseObjectEnumerator]) {
            [reverseCached addObject: obj];
        }
        self.flickrData = [reverseCached copy];
    };

}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSDictionary * fclickrObject = [[self.flickrData objectAtIndex: [self.tableView indexPathForCell: sender].row] copy];
    FPAppDelegate * fp = (FPAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    id dvc = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString: @"Show place detail"])
        [dvc setDatasource: fclickrObject];
    else if ([segue.identifier isEqualToString: @"Show photos from the place"])
        [dvc setFlickrPlace: fclickrObject];
    else if ([segue.identifier isEqualToString: @"Show the photo"]){
        [dvc setImageURL: [FlickrFetcher urlForPhoto: fclickrObject format: FlickrPhotoFormatLarge]];
        [dvc setImageSource: fp];
    } else if ([segue.identifier isEqualToString: @"Show a cached photo"]){
        [dvc setImageURL: [NSURL URLWithString: [fclickrObject objectForKey: @"name"]]];
        [dvc setImageSource: fp];
    }

    
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

- (void) viewDidAppear:(BOOL)animated {
    if (![[self flickrData] count] || [self.title isEqualToString: FP_CACHED_PHOTOS])
        [self refreshButtonPressed: nil];
}

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
    
    FPIdentifiableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSMutableDictionary * flickrObject = [self.flickrData objectAtIndex: indexPath.row];
    
    
    if (!cell) {
        NSLog(@"No cell for %@", cellIdentifier);
        cell = [[FPIdentifiableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    
    if ([cellIdentifier isEqualToString: TOP_PLACES_VIEW_TITLE]) {
        cell.textLabel.text = [flickrObject objectForKey: FLICKR_PLACE_NAME];
        
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ photos", [flickrObject objectForKey: FLICKR_PLACE_PHOTO_COUNT]];
    } else if ([cellIdentifier isEqualToString: FP_CACHED_PHOTOS]) {
        
        cell.textLabel.text = [flickrObject objectForKey: @"name"];
        
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ bytes", [[flickrObject objectForKey: @"size"] stringValue]];
        
        //cell.imageView.image = ?
        
    } else {
        
        NSString * photoId = [flickrObject objectForKey: FLICKR_PHOTO_ID];
        
        cell.identifier = [photoId copy];
        
        cell.textLabel.text = [flickrObject objectForKey: FLICKR_PHOTO_TITLE];
        
        if ([cell.textLabel.text isEqualToString:@""])
            cell.textLabel.text = @"Untitled";
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@",[flickrObject objectForKey: FLICKR_PHOTO_OWNER]];
        
        cell.imageView.image = [self.thumbnails objectForKey: photoId];
        
        if (!cell.imageView.image)
            cell.imageView.image = [UIImage imageNamed: @"Placeholder.png"]
        ;
        
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr thumbnailer", NULL);
        
        dispatch_async(downloadQueue, ^{
            UIImage * thumbnail = [[UIImage alloc] initWithData: [NSData dataWithContentsOfURL: [FlickrFetcher urlForPhoto:flickrObject format: FlickrPhotoFormatSquare]]];
            
            [self.thumbnails setObject: thumbnail forKey: photoId];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([cell.identifier isEqual:  photoId])
                    [[cell imageView] setImage: thumbnail];
                
            });
        });
        
        dispatch_release(downloadQueue);
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
