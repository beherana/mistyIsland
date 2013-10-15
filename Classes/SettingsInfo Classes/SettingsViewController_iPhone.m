//
//  SettingsViewController_iPhone.m
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "SettingsViewController_iPhone.h"
#import "ThomasSwitch.h"
#import "ThomasSettingsTVC_iPhone.h"
#import "cdaAnalytics.h"

@interface MyAppDelegate  : NSObject
-(BOOL) getSaveNarrationSetting;
-(void) setSaveNarrationSetting:(BOOL)value;
-(void) unloadSettings;
-(BOOL)getSaveReadEnlargeTextSetting;
-(void)setSaveReadEnlargeTextSetting:(BOOL)value;
-(BOOL)getSwipeInReadIsTurnedOff;
-(void)setSwipeInReadIsTurnedOff:(BOOL)b;
-(id)getCurrentLanguage;
-(UIViewController *)myRootViewController;
@end


@interface SettingsViewController_iPhone (topSecret)
-(void)presentHelp;
-(void)presentInfo;
-(void)slideInView:(UIView *)v;
-(void)slideOutView:(UIView *)v;	
-(void)enableMe;
@end

@implementation SettingsViewController_iPhone

@synthesize followShareView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(void) initWithParent: (id) parent
{
	myParent=parent;
	return;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	infoScrollView=nil;
	sectionLabel.textColor=[UIColor colorWithRed:128.0f/255.0f green:128.0f/255.0f blue:132.0f/255.0f alpha:1.0f];
	//later add custom seperator line per table cell
    tv.separatorColor= [UIColor clearColor];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //show the info image after the view has appeared since it does not fade in attractively
    topFadeImage.hidden = NO;
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [topFadeImage release];
    topFadeImage = nil;
    [copyrightView release];
    copyrightView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[sectionLabel release];
	[infoScrollView release];
	[backButton release];
	[tv release];
    [topFadeImage release];
    [copyrightView release];
    [super dealloc];
}
#pragma mark Callbacks
-(IBAction)backPressed:(UIButton *)sender{
	if (infoScrollView || self.followShareView) {
        if (infoScrollView) {
            [self slideOutView:infoScrollView];
        }
        if (self.followShareView) {
            [self slideOutView:self.followShareView.view];
        }
		
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *buttonImagePath = [bundle pathForResource:[NSString stringWithFormat:@"mainmenubutton_iPhone"] ofType:@"png"];
		[backButton setBackgroundImage:[UIImage imageWithContentsOfFile:buttonImagePath] forState:UIControlStateNormal];
		CGRect buttonframe = CGRectMake(0,5,49,45);
		backButton.frame = buttonframe;
		
	}
    else {
		NSLog(@"get out of settings here");
		[(MyAppDelegate *)myParent unloadSettings];
	}

	
}
-(void)textSettingsSwitched:(ThomasSwitch *)sw{
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Turning off/on Text Enlarge: %i", [sw isOn]]];
	
	
	MyAppDelegate *appdelegate=[NSClassFromString(@"Misty_Island_Rescue_iPadAppDelegate") performSelector:@selector(get)];
	[appdelegate setSaveReadEnlargeTextSetting:sw.isOn];
}
-(void)narrationSettingsSwitched:(ThomasSwitch *)sw{
	
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Turning off/on Narration: %i", [sw isOn]]];
	
	MyAppDelegate *appdelegate=[NSClassFromString(@"Misty_Island_Rescue_iPadAppDelegate") performSelector:@selector(get)];
	[appdelegate setSaveNarrationSetting:sw.isOn];
}
-(void)pageSwipeSettingsSwitched:(ThomasSwitch *)sw{
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Turning off/on Swipe: %i", [sw isOn]]];
	//
	MyAppDelegate *appdelegate=[NSClassFromString(@"Misty_Island_Rescue_iPadAppDelegate") performSelector:@selector(get)];
	[appdelegate setSwipeInReadIsTurnedOff:!sw.isOn];
	
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ThomasSettingsTVC_iPhone *cell = (ThomasSettingsTVC_iPhone *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ThomasSettingsTVC_iPhone alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //selection color for cell
        UIView *v = [[[UIView alloc] init] autorelease];
        v.backgroundColor = [UIColor colorWithRed:84.0f/255.0f green:188.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
        cell.selectedBackgroundView = v;
        
        //add a custom seperator
        UIView *rule= [[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height+12, tableView.frame.size.width, 1)];
        rule.backgroundColor=[UIColor colorWithRed:84.0f/255.0f green:188.0f/255.0f blue:275.0f/255.0f alpha:1.0f];
        [cell addSubview:rule];
        [rule release];
    }
    
    // Configure the cell...
	
	
	switch (indexPath.row) {
		case 0:{
			cell.textLabel.text=@"Enlarge text";
			MyAppDelegate *appdelegate=[NSClassFromString(@"Misty_Island_Rescue_iPadAppDelegate") performSelector:@selector(get)];
			[cell.s setOn:[appdelegate getSaveReadEnlargeTextSetting]];
			[cell setSwitchTarget:self selector:@selector(textSettingsSwitched:)];
		}break;
		case 1:{
			cell.textLabel.text=@"Narration";
			MyAppDelegate *appdelegate=[NSClassFromString(@"Misty_Island_Rescue_iPadAppDelegate") performSelector:@selector(get)];
			[cell.s setOn:[appdelegate getSaveNarrationSetting]];
			[cell setSwitchTarget:self selector:@selector(narrationSettingsSwitched:)];
		}break;
		case 2:{
			cell.textLabel.text=@"Page Swipe";
			MyAppDelegate *appdelegate=[NSClassFromString(@"Misty_Island_Rescue_iPadAppDelegate") performSelector:@selector(get)];
			[cell.s setOn:![appdelegate getSwipeInReadIsTurnedOff]];
			[cell setSwitchTarget:self selector:@selector(pageSwipeSettingsSwitched:)];
		}break;
        case 3:{
			cell.textLabel.text=@"Follow and Share";
		}break;
		case 4:{
			cell.textLabel.text=@"Help";
		}break;
		case 5:{
			cell.textLabel.text=@"Information";
		}break;
		default:
			break;
	}
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	switch (indexPath.row) {
        case 3:{
			[self presentFollowShare];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}break;
		case 4:{
			[self presentHelp];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}break;
		case 5:{
			[self presentInfo];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}break;
		default:
			break;
	}

}
#pragma mark Misc
-(void)presentFollowShare {
    // allocate end page ticket view
    if (self.followShareView == nil) {
        SettingsFollowShareViewController *tmp = [SettingsFollowShareViewController alloc];
        self.followShareView = [tmp initWithNibName:@"SettingsFollowShareViewController" bundle:nil];
        [tmp release];
    }
    
    self.followShareView.view.frame = CGRectMake(20, 61, 440, 320-61);
    
    //Back button
    NSBundle *bundle = [NSBundle mainBundle];
	NSString *buttonImagePath = [bundle pathForResource:[NSString stringWithFormat:@"infosettingsbackbutton"] ofType:@"png"];
	[backButton setBackgroundImage:[UIImage imageWithContentsOfFile:buttonImagePath] forState:UIControlStateNormal];
	CGRect buttonframe = CGRectMake(5,4,47,47);
	backButton.frame = buttonframe;
    
    //label
    sectionLabel.text=@"Follow and Share";
	sectionLabel.alpha=0.0f;
	sectionLabel.hidden=NO;
    [self slideInView:self.followShareView.view];
}

-(void)presentHelp{
	infoScrollView=[[SettingsInformationScroll_iPhone alloc]initWithFrame:CGRectMake(20, 62, 440, 320-62)];
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *buttonImagePath = [bundle pathForResource:[NSString stringWithFormat:@"infosettingsbackbutton"] ofType:@"png"];
	[backButton setBackgroundImage:[UIImage imageWithContentsOfFile:buttonImagePath] forState:UIControlStateNormal];
	CGRect buttonframe = CGRectMake(5,4,47,47);
	backButton.frame = buttonframe;
	
	NSString * currentlanguage = [(MyAppDelegate *)myParent getCurrentLanguage];
	NSLog(@"This is current language: %@", currentlanguage);
	//FIXME: you may need to implement @2x yourself as I am not sure I want to use imageNamed: 
	//NSString *imageName=@"TAF002_MistyIslandRescue_HelpPg_US.png";
	//if ([currentlanguage isEqualToString:@"en_GB"]) imageName=@"TAF002_MistyIslandRescue_HelpPg_UK.png";
	//[infoScrollView setContentsImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]]];
	
	//change to make ~iphone/~ipad and @2x work
	NSString *imageName = [bundle pathForResource:[NSString stringWithFormat:@"TAF002_MistyIslandRescue_HelpPg_US"] ofType:@"png"];
	if ([currentlanguage isEqualToString:@"en_GB"]) imageName = [bundle pathForResource:[NSString stringWithFormat:@"TAF002_MistyIslandRescue_HelpPg_UK"] ofType:@"png"];
	[infoScrollView setContentsImage:[UIImage imageWithContentsOfFile:imageName]];
	MyAppDelegate *appdelegate=[NSClassFromString(@"Misty_Island_Rescue_iPadAppDelegate") performSelector:@selector(get)];
	
	infoScrollView.vc=[appdelegate myRootViewController];
	[infoScrollView addEmailButton];
	//
	sectionLabel.text=@"Help";
	sectionLabel.alpha=0.0f;
	sectionLabel.hidden=NO;
	
	[self slideInView:infoScrollView];
}

-(void)presentInfo{
	infoScrollView=[[SettingsInformationScroll_iPhone alloc]initWithFrame:CGRectMake(20, 62, 440, 320-62)];
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *buttonImagePath = [bundle pathForResource:[NSString stringWithFormat:@"infosettingsbackbutton"] ofType:@"png"];
	[backButton setBackgroundImage:[UIImage imageWithContentsOfFile:buttonImagePath] forState:UIControlStateNormal];
	CGRect buttonframe = CGRectMake(5,4,47,47);
	backButton.frame = buttonframe;
	
	//FIXME: you may need to implement @2x yourself as I am not sure I want to use imageNamed: 
	//NSString *imageName=@"TAF002_MistyIslandRescue_InfoPg.png";
	//[infoScrollView setContentsImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]]];
	
	//change to make ~iphone/~ipad and @2x work
	NSString *imageName = [bundle pathForResource:[NSString stringWithFormat:@"TAF002_MistyIslandRescue_InfoPg"] ofType:@"png"];
	//NSString *imageName = [bundle pathForResource:[NSString stringWithFormat:[self imagePathForResolution:@"TAF002_MistyIslandRescue_InfoPg"]] ofType:@"png"];
	[infoScrollView setContentsImage:[UIImage imageWithContentsOfFile:imageName]];
    NSLog(@"this is imageName: %@", imageName);
    
    //Copy right text
    if (copyrightView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SettingsInfoCopyrightText" owner:self options:nil];
    }
    copyrightView.frame = CGRectMake(0, infoScrollView.sv.contentSize.height+5, copyrightView.frame.size.width, copyrightView.frame.size.height);    
    //get current scroll view size and extend it
    CGSize scrollViewSize = infoScrollView.sv.contentSize;
    //add some padding to the scrollview
    scrollViewSize.height += copyrightView.frame.size.height;
    infoScrollView.sv.contentSize = scrollViewSize;
    [infoScrollView.sv addSubview:copyrightView];


    //Version Label
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    UILabel *versionLabel = [[UILabel alloc] init];
	versionLabel.text = [NSString stringWithFormat:@"Thomas & Friends Misty Island Rescue: Version %@", [bundleInfo objectForKey:@"CFBundleVersion"]];
    [versionLabel setFont:[UIFont fontWithName:@"Georgia" size:11]];
    [versionLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    
    //append label to scrollview
    versionLabel.frame = CGRectMake(7, infoScrollView.sv.contentSize.height, infoScrollView.sv.contentSize.width, 40);    
    //get current scroll view size and extend it
    scrollViewSize = infoScrollView.sv.contentSize;
    //add some padding to the scrollview
    scrollViewSize.height += versionLabel.frame.size.height + 20;
    infoScrollView.sv.contentSize = scrollViewSize;
    
    [infoScrollView.sv addSubview:versionLabel];
    [versionLabel release];
    
    
    //add links to callaway and hit webpage
    [infoScrollView addHomepageLinkButtons];
    
	//[infoScrollView setContentsImage:[UIImage imageWithContentsOfFile:imageName]];
	//
	//UIImageView *tempView = [[UIImageView alloc] initWithImage:
	//[infoScrollView setContentsImage:[UIImage imageNamed:@"TAF002_MistyIslandRescue_InfoPg.png"]];
	sectionLabel.text=@"Information";
	sectionLabel.alpha=0.0f;
	sectionLabel.hidden=NO;
	[self slideInView:infoScrollView];
    
    
}

-(void)slideInView:(UIView *)v{
	self.view.userInteractionEnabled=NO;
	tvIndentFrame=tv.frame;
	v.frame=CGRectMake(self.view.frame.size.width+v.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
	v.alpha=0.0f;
	[self.view addSubview:v];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(enableMe)];
	sectionLabel.alpha=1;
	v.frame=CGRectMake(tv.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
	tv.frame=CGRectMake(tv.frame.origin.x-self.view.frame.size.width, tv.frame.origin.y, tv.frame.size.width, tv.frame.size.height);
	v.alpha=1.0f;
	tv.alpha=0.0f;
	[UIView commitAnimations];
	
}
-(void)slideOutView:(UIView *)v{

	self.view.userInteractionEnabled=NO;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeInfoScrollView)];
	sectionLabel.alpha=0.0f;
	v.frame=CGRectMake(self.view.frame.size.width+v.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
	v.alpha=0.0f;
	tv.frame=tvIndentFrame;
	
	tv.alpha=1.0f;
	[UIView commitAnimations];
	
}
-(void)removeInfoScrollView{
	[self enableMe];
    if (infoScrollView != nil) {
	[infoScrollView removeFromSuperview];
	[infoScrollView release];
	infoScrollView=nil;
    }
    if (self.followShareView != nil) {
        [self.followShareView.view removeFromSuperview];
        self.followShareView = nil;
    }
    
}
-(void)enableMe{
self.view.userInteractionEnabled=YES;
}

#pragma mark -
#pragma mark junkyard
-(NSString*)imagePathForResolution:(NSString*)path {
	if ([[UIScreen mainScreen] scale] == 2.0 ) {
		path = [NSString stringWithFormat:@"%@" @"%@", path, @"@2x"];
	}
	NSLog(@"This is what we get from imagePathForResolution: %@", path);
	return path;
}
@end
