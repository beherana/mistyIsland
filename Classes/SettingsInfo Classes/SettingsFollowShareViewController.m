//
//  SettingsFollowShareViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-27.
//  Copyright 2011 Commind. All rights reserved.
//

#import "SettingsFollowShareViewController.h"
#import "NetworkUtils.h"

@implementation SettingsFollowShareViewController

@synthesize willOpenUrl = _willOpenUrl;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *lineColor = [UIColor colorWithRed:84.0f/255.0f green:188.0f/255.0f blue:275.0f/255.0f alpha:1.0f];
    self.tableView.separatorColor = lineColor;

    //hack to set a top separator line in the table view
    UIView *rule=[[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)] autorelease];
    rule.backgroundColor= lineColor;
    [rule setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:rule];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        //font and color
        UIView *v = [[[UIView alloc] init] autorelease];
        v.backgroundColor = [UIColor colorWithRed:84.0f/255.0f green:188.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
        cell.selectedBackgroundView = v;
        
        cell.textLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:156.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
        [cell.textLabel setFont:[UIFont fontWithName:@"Arial" size:22]];
    }
    
    // Configure the cell...
    UILabel *cellLabel = cell.textLabel;
    switch (indexPath.row) {
		case 0:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"facebook_icon" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = theImage;
			cellLabel.text=@"Like Thomas & Friends";
		}break;
		case 1:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"twitter_icon" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = theImage;
			cellLabel.text=@"Follow Thomas & Friends";
		}break;
        case 2:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"thomas_website_icon" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = theImage;
			cellLabel.text=@"Thomas & Friends Official Website";
		}break;
		default:
			break;
	}
    
        
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    //hack to get rid of empty rows in the table
    return [[UIView new] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0f;
}

#pragma mark -
#pragma mark linking
- (void)CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value
{
    //deselect all images ... harcoded =)
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES];
    
    if (alert.view.tag == CAVCLeaveToWebsiteAlert) {
        if ([value isEqualToString:@"Continue"]) {
            [[UIApplication sharedApplication] openURL:self.willOpenUrl];
        }
    }
    
    [self deselectAllRows];
    self.willOpenUrl = nil;
}

- (void) CAVCWasCancelled:(CustomAlertViewController *)alert {
    [self deselectAllRows];
}

-(void)deselectAllRows {
    for (int i=0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
    }
}

//leaving app or no network dialogue
- (void)showLeavingAppAlert
{
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    alert.view.tag = [NetworkUtils connectedToNetwork] ? CAVCLeaveToWebsiteAlert : CAVCInternetAlert;
    [alert show:[self.view superview]];
    [alert release];	
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{
            self.willOpenUrl = [NSURL URLWithString:@"http://www.facebook.com/Thomasandfriends"];
            
            [self showLeavingAppAlert];
        }break;
        case 1:{
            self.willOpenUrl = [NSURL URLWithString:@"http://twitter.com/#!/trueblueengine"];
            
            [self showLeavingAppAlert];
        }break;
        case 2:{
            self.willOpenUrl = [NSURL URLWithString:@"http://m.thomasandfriends.com"];
            
            [self showLeavingAppAlert];
        }break;
        default:
            break;
    }
}

@end
