//
//  PaintHolderLandscapeViewController.m
//  Book
//
//  Created by Henrik Nord on 9/14/08.
//  Copyright 2008 Haunted House. All rights reserved.
//

#import "PaintHolderLandscapeViewController.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"

#import "cdaAnalytics.h"

#define kNumberOfPaintImages 10
#define kNumberOfPaintImagesOnIphone 6

@interface PaintHolderLandscapeViewController (PrivateMethods)
- (void) setPaintStartValues;
-(void) createImageArr;
-(void)wantsToSave;
-(void) resetText;
-(void) hideIPhonePaintPalette;
@end

@implementation PaintHolderLandscapeViewController

@synthesize imageSelectArr;
@synthesize lineart;

#pragma mark -
#pragma mark INIT 

- (void)viewDidLoad {
	/**/
	//NSLog(@"PaintHolderLandscapeView has loaded");
    [super viewDidLoad];
	
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	// set start brushsize and start color
	int brush = [appDelegate getSaveCurrentPaintBrush];
	NSString *selectpath = [NSString stringWithFormat:@"brushsize_%i" "_select.png", brush];
	UIImage *tempSelectImage = [UIImage imageNamed:selectpath];
	switch (brush) {
		case 1:
			brushsize1.image = tempSelectImage;
			break;
		case 2:
			brushsize2.image = tempSelectImage;
			break;
		case 3:
			brushsize3.image = tempSelectImage;
			break;
		case 4:
			brushsize4.image = tempSelectImage;
			break;
		case 5:
			brushsize5.image = tempSelectImage;
			break;
		default:
			break;
	}
	brushsize = brush;
	
	
	//If on iPhone init the painting from here
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		iPhoneMode = YES;
		UKexception = 5;
		int selectedPaintImage = [appDelegate getSaveCurrentPaintImage];
		[self refreshPaintImage:selectedPaintImage];
		paletteGhosting.hidden = YES;
		paletteGhosting.alpha = 0.0;
	} else {
		iPhoneMode = NO;
		UKexception = 6;
	}
	
	//first color - get color from saved index
	if (iPhoneMode) {
		//CGColorRef color = [[[[iPhonePaintPalette subviews] objectAtIndex:[appDelegate getSaveCurrentPaintColor]] backgroundColor] CGColor];
		CGColorRef color = [[[iPhonePaintPalette viewWithTag:[appDelegate getSaveCurrentPaintColor]] backgroundColor] CGColor];
		int numComponents = CGColorGetNumberOfComponents(color);
		if (numComponents == 4)
		{
			const CGFloat *components = CGColorGetComponents(color);
			red = components[0];
			green = components[1];
			blue = components[2];
			alfa = components[3];
			alfa/=2;
		}	
	} else {
		CGColorRef color = [[[[self.view subviews] objectAtIndex:[appDelegate getSaveCurrentPaintColor]] backgroundColor] CGColor];
		int numComponents = CGColorGetNumberOfComponents(color);
		if (numComponents == 4)
		{
			const CGFloat *components = CGColorGetComponents(color);
			red = components[0];
			green = components[1];
			blue = components[2];
			alfa = components[3];
			alfa/=2;
		}
	}
	//
	paintInsideLines = YES;
	paintOnTop = NO;
	paintOnEmptyCanvas = NO;
	//
	 
}
#pragma mark -
#pragma mark Getters and Setters
- (BOOL) setSaveImageWarning {
	saveImageWarning = YES;
	return YES;
}
-(BOOL)shouldPaintInsideLines {
	if (paintInsideLines) {
		paintInsideLines = NO;
		return NO;
	} else {
		paintInsideLines = YES;
		return YES;
	}
}
-(BOOL)shouldPaintOnTop {
	if (paintOnTop) {
		paintOnTop = NO;
		return NO;
	} else {
		paintOnTop = YES;
		return YES;
	}
}
-(BOOL)shouldPaintOnEmptyCanvas {
	if (paintOnEmptyCanvas) {
		paintOnEmptyCanvas = NO;
		return NO;
	} else {
		paintOnEmptyCanvas = YES;
		return YES;
	}
}
-(BOOL)getShouldPaintInsideLines {
	return paintInsideLines;
}
-(BOOL)getShouldPaintOnTop {
	return paintOnTop;
}
-(BOOL)getShouldPaintOnEmptyCanvas {
	return paintOnEmptyCanvas;
}
- (void) setPaintStartValues {
	paintOnTop = NO;
	paintInsideLines = NO;
	paintOnEmptyCanvas = NO;
}
-(int) getCurrentPaintImage {
	return currentPaintImage;
}
-(float) getCurrentBrushsize {
	//NSLog(@"this is the returner brushsize: %f", brushsize);
	return brushsize;
}
-(float) getRedColor {
	//NSLog(@"this is the returner brushsize: %f", brushsize);
	return red;
}
-(float) getGreenColor {
	return green;
}
-(float) getBlueColor {
	return blue;
}
-(float) getAlfaColor {
	return alfa;
}
#pragma mark -
#pragma mark iPhone related functions
- (IBAction) returnToPaintMenuFromPaint:(id)sender {

	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate.myRootViewController navigateFromMainMenuWithItem:5];
}

-(IBAction) showIPhonePaintPalette:(id) sender {
	if (!iPhonePaintPaletteShown) {
		paletteGhosting.hidden = NO;
	}
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(paletteHidden:finished:context:)];
	[UIView setAnimationDuration:0.3];
	if (iPhonePaintPaletteShown) {
		//hide it
		iPhonePaintPalette.transform = CGAffineTransformIdentity;
		paletteGhosting.alpha = 0.0;
		iPhonePaintPaletteShown = NO;
	} else {
		//show it
		iPhonePaintPalette.transform = CGAffineTransformTranslate(iPhonePaintPalette.transform , 0.0, -141);
		paletteGhosting.alpha = 1.0;
		iPhonePaintPaletteShown = YES;
	} 
	[UIView commitAnimations];
}
-(void) hideIPhonePaintPalette {
	iPhonePaintPaletteShown = NO;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(paletteHidden:finished:context:)];
	[UIView setAnimationDuration:0.3];
	iPhonePaintPalette.transform = CGAffineTransformIdentity;
	paletteGhosting.alpha = 0.0;
	[UIView commitAnimations];
}

-(void)paletteHidden:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	if (!iPhonePaintPaletteShown) {
		paletteGhosting.hidden = YES;
	}
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	int tag = touch.view.tag;
	if (tag == 100) {
		[self hideIPhonePaintPalette];
	}
}
#pragma mark -
#pragma mark PaintMenu
-(void) retractPaintMenu {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.4];
	changeImageHolder.alpha = 0.0;
	saveImageHolder.alpha = 0.0;
	[UIView commitAnimations];
}
-(void) restorePaintMenu {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	changeImageHolder.alpha = 1.0;
	saveImageHolder.alpha = 1.0;
	[UIView commitAnimations];
}
#pragma mark -
#pragma mark Paint Images 
- (void) createImageArr {
	//create the image array
	[imageSelectArr removeAllObjects];
	NSMutableArray *myimageselects = [[NSMutableArray alloc] init];
	if (iPhoneMode) {
		for (unsigned i = 0; i < kNumberOfPaintImagesOnIphone; i++) {
			[myimageselects addObject:[NSNull null]];
		}
		for (unsigned i = 0; i < kNumberOfPaintImagesOnIphone; i++) {
			[myimageselects replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:i+1]];
		}
	} else {
		for (unsigned i = 0; i < kNumberOfPaintImages; i++) {
			[myimageselects addObject:[NSNull null]];
		}
		for (unsigned i = 0; i < kNumberOfPaintImages; i++) {
			[myimageselects replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:i+1]];
		}
	}
	self.imageSelectArr = myimageselects;
	[myimageselects release];
	myimageselects = nil;
	
}
-(IBAction) refreshThePaintImage {
	//[self refreshPaintImage];
}
-(void)refreshPaintImage:(int)image {
	currentPaintImage = image;
	//FLURRY	
	[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"PAINT image refreshed with image: %i", currentPaintImage]];
	//
	[self setPaintStartValues];
	if (paintViewController != nil) {
		//NSLog(@"paintViewController isn't nil something should be removed and then show up again");
		[paintViewController.view removeFromSuperview];
		[lineart removeFromSuperview];
		[paintViewController release];
		paintViewController = nil;
		//reinit
		paintViewController = [[PaintViewController alloc] initWithNibName:@"PaintView" bundle:[NSBundle mainBundle]];
		[paintArea addSubview:paintViewController.view];
		[paintViewController.view initWithParent:self];
		//Now - lets try to add the image itself and it's mask...
		NSBundle *bundle = [NSBundle mainBundle];
		//
		Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
		NSString *basePath = @"";
		if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"] && currentPaintImage == UKexception) {
			basePath = [bundle pathForResource:[NSString stringWithFormat:@"paint_%i" "_base_UK", currentPaintImage] ofType:@"png"];
		} else {
			basePath = [bundle pathForResource:[NSString stringWithFormat:@"paint_%i" "_base", currentPaintImage] ofType:@"png"];
		}
		NSLog(@"This is image basePath: %@", basePath);
		UIImage *templineartImg = [UIImage imageWithContentsOfFile:basePath];
		UIImageView *templineartImgView = [[UIImageView alloc] initWithImage:templineartImg];
		
		self.lineart = templineartImgView;
		
		[templineartImgView release];
		
		[paintArea addSubview:lineart];
		
	} else {
		paintViewController = [[PaintViewController alloc] initWithNibName:@"PaintView" bundle:[NSBundle mainBundle]];
		[paintArea addSubview:paintViewController.view];
		[paintViewController.view initWithParent:self];
		NSBundle *bundle = [NSBundle mainBundle];
		Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
		NSString *basePath = @"";
		if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"] && currentPaintImage == UKexception) {
			basePath = [bundle pathForResource:[NSString stringWithFormat:@"paint_%i" "_base_UK", currentPaintImage] ofType:@"png"];
		} else {
			basePath = [bundle pathForResource:[NSString stringWithFormat:@"paint_%i" "_base", currentPaintImage] ofType:@"png"];
		}
		NSLog(@"This is image basePath: %@", basePath);
		UIImage *templineartImg = [UIImage imageWithContentsOfFile:basePath];
		UIImageView *templineartImgView = [[UIImageView alloc] initWithImage:templineartImg];
		
		self.lineart = templineartImgView;
		
		[templineartImgView release];
		
		[paintArea addSubview:lineart];
	}
	
}
#pragma mark -
#pragma mark Colors & brushes
- (IBAction)colorPushed:(id)sender {
	if (iPhoneMode) {
		[self hideIPhonePaintPalette];
	}
	CGColorRef color = [[(UIButton *)sender backgroundColor] CGColor];
	int numComponents = CGColorGetNumberOfComponents(color);
	if (numComponents == 4)
	{
		const CGFloat *components = CGColorGetComponents(color);
		red = components[0];
		green = components[1];
		blue = components[2];
		alfa = components[3];
		alfa/=2;
	}
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if (iPhoneMode) {
		[appDelegate setSaveCurrentPaintColor:[(UIButton*)sender tag]];
	} else {
		[appDelegate setSaveCurrentPaintColor:[[self.view subviews] indexOfObject:(UIButton*)sender]];
	}
}
-(IBAction)brushSizeButtonPushed:(id)sender {
	int check = brushsize;
	int newsize = [(UIButton *)sender tag]-18;
	if (brushsize == newsize) {
		return;
	} else {
		brushsize = newsize;
	}
	if (iPhoneMode) {
		[self hideIPhonePaintPalette];
	}
	NSString *restorepath = [NSString stringWithFormat:@"brushsize_%i" ".png", check];
	UIImage *tempRestoreImage = [UIImage imageNamed:restorepath];
	switch (check) {
		case 1:
			brushsize1.image = tempRestoreImage;
			break;
		case 2:
			brushsize2.image = tempRestoreImage;
			break;
		case 3:
			brushsize3.image = tempRestoreImage;
			break;
		case 4:
			brushsize4.image = tempRestoreImage;
			break;
		case 5:
			brushsize5.image = tempRestoreImage;
			break;
		default:
			break;
	}
	check = brushsize;
	NSString *selectpath = [NSString stringWithFormat:@"brushsize_%i" "_select.png", check];
	UIImage *tempSelectImage = [UIImage imageNamed:selectpath];
	switch (check) {
		case 1:
			brushsize1.image = tempSelectImage;
			break;
		case 2:
			brushsize2.image = tempSelectImage;
			break;
		case 3:
			brushsize3.image = tempSelectImage;
			break;
		case 4:
			brushsize4.image = tempSelectImage;
			break;
		case 5:
			brushsize5.image = tempSelectImage;
			break;
		default:
			break;
	}
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate setSaveCurrentPaintBrush:brushsize];
}
#pragma mark -
#pragma mark Sounds
-(IBAction)buttonSoundFX:(id)sender {
	
	int newsize = [(UIButton *)sender tag]-18;
	if (brushsize == newsize) return;
		
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	//play eventsound
	[appDelegate playFXEventSound:@"Select"];
}
#pragma mark -
#pragma mark Saving and warnings
- (IBAction)saveimage:(id)sender {
	
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:@"PAINT - Tapped save image button"];
    
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    alert.view.tag = CAVCPaintSaveAlert;
    
    UIView *v = alert.backgroundView;
    v.tag = 0xdecafbad;
    [v removeFromSuperview];
    [appDelegate.myRootViewController.view addSubview:v];
    [UIView animateWithDuration:0.2555 animations:^{
        v.alpha = 1.0;
    }];
    
    [alert show:appDelegate.myRootViewController.view withOverlay:NO];
    [alert release];	

	/* old alert code
	saveText2.text = @"Saving...";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saving Painting" message:@"Do you want to save your painting to your Photos Library?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"YES", nil];
	[alert show];
	[alert release];
     */
}

- (void) CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value {
    if(alert.view.tag == CAVCPaintSaveAlert) {
        [self wantsToSave];			
    } else {
        UIView *v = [[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController].view viewWithTag:0xdecafbad];
        [UIView animateWithDuration:0.2555
                         animations:^(void) {
                             v.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [v removeFromSuperview];
                         }];
    }
}
/*old alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		//NSLog(@"This is button 0");
		[self resetText];
	} else if (buttonIndex == 1) {
		//NSLog(@"This is button 1");
		[self wantsToSave];			
	}
}*/

- (void)CAVCWasCancelled:(CustomAlertViewController *)alert {
    UIView *v = [[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController].view viewWithTag:0xdecafbad];
    [UIView animateWithDuration:0.2555
                     animations:^(void) {
                         v.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [v removeFromSuperview];
                     }];
}

-(void)wantsToSave {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        UIGraphicsBeginImageContext(paintArea.bounds.size);
        [paintArea.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(viewImage, self, nil, nil);
    });
		
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:@"PAINT - Image was saved"];
	
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    alert.view.tag = CAVCPaintSavedAlert;
    [alert show:appDelegate.myRootViewController.view withOverlay:NO];
    [alert release];

	/*old alert
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save completed!" message:@"The painting has been saved to your Photos Library." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
     */
	
	[self performSelector:@selector(resetText) withObject:nil afterDelay:0.8];
}
-(void) resetText {
	
	saveText2.text = @"Save image";
	
}
#pragma mark -
#pragma mark Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}
- (void) dealloc
{
	[brushSizeButton release];
	[paintArea release];
	[paintFrame release];
	[shakeToChangeText release];
	[changeText release];
	[changeText2 release];
	[saveText release];
	[saveText2 release];
	
	[brushsize1 release];
	[brushsize2 release];
	[brushsize3 release];
	[brushsize4 release];
	[brushsize5 release];
	
	[save release];
	[changeImage release];
	
	[changeImageHolder release];
	[saveImageHolder release];
	
	[imageSelectArr release];
	[paintViewController.view removeFromSuperview];
	[paintViewController release];
	paintViewController = nil;
	
	[lineart release];
	
	[iPhonePaintPalette release];
	
	[super dealloc];
	
}


@end
