//
//  Misty_Island_Rescue_iPadAppDelegate.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/9/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "cdaAnalyticsGoogleTracker.h"
#import "cdaAnalyticsFlurryTracker.h"
#import "UAirship.h"
#import "UAPush.h"

//Save data
#define kSelectedAppSection @"kSelectedAppSection"
#define kLastVisitedMenuItem @"kLastVisitedMenuItem"
#define kCurrentReadPage @"kCurrentReadPage"
#define kReadNarrationSetting @"kReadNarrationSetting"
#define kReadEnlargeTextSetting @"kReadEnlargeTextSetting"
#define kReadMusicSetting @"kReadMusicSetting"
#define kCurrentPaintImage @"kCurrentPaintImage"
#define kCurrentBrushSize @"kCurrentBrushSize"
#define kCurrentPaintColor @"kCurrentPaintColor"
#define kCurrentPuzzle @"kCurrentPuzzle"
#define kPuzzleDifficulty @"kPuzzleDifficulty"
#define kCurrentDotImage @"kCurrentDotImage"
#define kDotDifficulty @"kDotDifficulty"
#define kRunningNarrationTime @"kRunningNarrationTime"
#define kOldSavedDate @"kOldSavedDate"
#define kNarrationDelayTime @"kNarrationDelayTime"
#define kIntroPresentationPlayed @"kIntroPresentationPlayed"
#define kRunningHotspotsTime @"kRunningHotspotsTime"
#define kOldSavedHotspotsDate @"kOldSavedHotspotsDate"
#define kHotspotsDelayTime @"kHotspotsDelayTime"
#define kSwipeInReadIsTurnedOff @"kSwipeInReadIsTurnedOff"

@interface Misty_Island_Rescue_iPadAppDelegate (PrivateMethods)
//INITS
-(void) setupRootViewController;
//langcheck
- (bool)isLanguage:(NSString*)checkLanguage;
- (bool)isRegion:(NSString*)checkRegion;
@end


@implementation Misty_Island_Rescue_iPadAppDelegate

@synthesize window;
@synthesize audioPlayer, fxPlayer, speakerPlayer, interfaceSounds, introPresentation, endSound;
@synthesize currentPaintImage; //TEMP to fix
@synthesize myRootViewController;


#pragma mark -
#pragma mark Application lifecycle
+ (void) initialize {	
	if ([self class] == [Misty_Island_Rescue_iPadAppDelegate class]) {
		//prefs
		NSString *appsection = @"2";
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) appsection = @"3";
		NSString *lastvisited = @"2";
		NSString *readpage = @"0";
		NSString *narration = @"YES";
		NSNumber *enlarge=[NSNumber numberWithBool:YES];
		NSString *music = @"YES";
		NSString *paintimage = @"1";
		NSString *paintbrush = @"3";
		NSString *paintcolor = @"6";
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) paintcolor = @"10";
		NSString *puzzle = @"3";
		NSString *puzzledifficulty = @"0";
		NSString *dotimage = @"1";
		NSString *dotdifficulty = @"0";
		NSString *narrationtime = [NSString stringWithFormat:@"0"];
		NSString *narrationdelay = @"0";
		NSDate *now = [NSDate date];
		NSString *intropresentation = @"NO";
		NSString *swipeturnedoff = @"YES";
		
		
		NSDictionary *defaults =  [NSDictionary dictionaryWithObjectsAndKeys: appsection, kSelectedAppSection, readpage, kCurrentReadPage, enlarge,kReadEnlargeTextSetting,narration, kReadNarrationSetting,
								   music, kReadMusicSetting, paintimage, kCurrentPaintImage, paintbrush, kCurrentBrushSize, paintcolor, kCurrentPaintColor, puzzle, kCurrentPuzzle,
								   puzzledifficulty, kPuzzleDifficulty, dotimage, kCurrentDotImage, dotdifficulty, kDotDifficulty, narrationtime, kRunningNarrationTime, now, kOldSavedDate,
								   narrationdelay, kNarrationDelayTime, intropresentation, kIntroPresentationPlayed, narrationtime, kRunningHotspotsTime, narrationdelay, kHotspotsDelayTime, 
								   now, kOldSavedHotspotsDate, swipeturnedoff, kSwipeInReadIsTurnedOff, lastvisited, kLastVisitedMenuItem, nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
		
	}
}

//Flurry Error handling
void uncaughtExceptionHandler(NSException *exception) {
    NSString *msg=[NSString stringWithFormat:@"Crash Stack: %@", [NSThread callStackSymbols]];
    [[cdaAnalytics sharedInstance] logError:@"Uncaught" withMessage:msg andException:exception];
} 


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	//ANALYTICS
    cdaAnalyticsFlurryTracker* flurryTracker = nil;
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#if defined DEBUG || defined ENTERPRISE || defined DISTRIBUTION || defined ADHOC    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		iPhoneMode = YES;
		//TEST
        flurryTracker = [[[cdaAnalyticsFlurryTracker alloc] initWithAPIKey:@"MUAMXXEZUYJGJ32BWVSD"] autorelease];
	} else {
		iPhoneMode = NO;
		//TEST
        flurryTracker = [[[cdaAnalyticsFlurryTracker alloc] initWithAPIKey:@"E461P4NQELMQWNXR86SE"] autorelease];
	}
    //test google analytics
    cdaAnalyticsGoogleTracker* gaTracker = [[[cdaAnalyticsGoogleTracker alloc] initWithAPIKey:@"UA-30546256-1"] autorelease];
#else
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		iPhoneMode = YES;
		//LIVE
        flurryTracker = [[[cdaAnalyticsFlurryTracker alloc] initWithAPIKey:@"7JURAJWIGTI7QVARU8VP"] autorelease];
	} else {
		iPhoneMode = NO;
		//LIVE
        flurryTracker = [[[cdaAnalyticsFlurryTracker alloc] initWithAPIKey:@"UFY5XGSNB1YFVHXQIUNI"] autorelease];
	}
    //live google analytics
    cdaAnalyticsGoogleTracker* gaTracker = [[[cdaAnalyticsGoogleTracker alloc] initWithAPIKey:@"UA-30552838-1"] autorelease];
#endif
    [[cdaAnalytics sharedInstance] registerProvider:flurryTracker setSessionReportsOnCloseEnabled:NO];
    [[cdaAnalytics sharedInstance] registerProvider:gaTracker];
	
    //Init Airship launch options
#if (!TARGET_IPHONE_SIMULATOR)
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
#endif
    
    NSMutableDictionary *airshipConfigOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [airshipConfigOptions setValue:@"sEJ2uqWSQZKOjWu7fipk-w" forKey:@"DEVELOPMENT_APP_KEY"];
    [airshipConfigOptions setValue:@"mmn3kLXPSvaxMAJE6XBqEQ" forKey:@"DEVELOPMENT_APP_SECRET"];

    [airshipConfigOptions setValue:@"lglVPS3xQ3ygJn1k8eCoNw" forKey:@"PRODUCTION_APP_KEY"];
    [airshipConfigOptions setValue:@"3tVmc4kwT26gpRylMCKc0g" forKey:@"PRODUCTION_APP_SECRET"];
    
    
#ifdef DEBUG
    [airshipConfigOptions setValue:@"NO" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
#else
    [airshipConfigOptions setValue:@"YES" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
#endif
    
#if (!TARGET_IPHONE_SIMULATOR)    
    [takeOffOptions setValue:airshipConfigOptions forKey:UAirshipTakeOffOptionsAirshipConfigKey];
    
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];

    [[UAPush shared] resetBadge];//zero badge on startup

    [[UAPush shared] registerForRemoteNotificationTypes: (UIRemoteNotificationType)
                                                        (UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
    
#endif
    
    
    
    [self loadPrefs];
	
	//[self setupAudioSession];
	
	[self setupRootViewController];
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSString * alertText=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    [[[[UIAlertView alloc] initWithTitle:@"Alert" message:alertText delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]autorelease]show];
    
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA
#if (!TARGET_IPHONE_SIMULATOR)
    [[UAirship shared] registerDeviceToken:deviceToken];
#endif
    
    //We can collect the device tokens here:
    
    //TODO: Extra options:
    /*
     - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
     UALOG(@"APN device token: %@", deviceToken);
     
     // Create a few tags
     NSMutableArray *tags = [NSMutableArray arrayWithObjects:@"Tag1", @"Tag2", @"Tag3", nil];
     NSDictionary *info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tags, @"tags", nil];
     
     // Updates the device token and registers the token with UA
     [[UAirship shared] registerDeviceToken:deviceToken withExtraInfo:info];
     }
     */
}


-(void)loadPrefs {
	//Restore prefs
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	saveSelectedAppSection = [standardUserDefaults integerForKey:kSelectedAppSection];
	saveLastVisitedMenuItem = [standardUserDefaults integerForKey:kLastVisitedMenuItem];
	saveCurrentReadPage = [standardUserDefaults integerForKey:kCurrentReadPage];
	saveReadNarrationSetting = [standardUserDefaults boolForKey:kReadNarrationSetting];
	saveReadEnlargeTextSetting = [standardUserDefaults boolForKey:kReadEnlargeTextSetting];
	saveReadMusicSetting = [standardUserDefaults boolForKey:kReadMusicSetting];
	saveCurrentPaintImage = [standardUserDefaults integerForKey:kCurrentPaintImage];
	saveCurrentPaintBrush = [standardUserDefaults integerForKey:kCurrentBrushSize];
	saveCurrentPaintColor = [standardUserDefaults integerForKey:kCurrentPaintColor];
	saveCurrentPuzzle = [standardUserDefaults integerForKey:kCurrentPuzzle];
	savePuzzleDifficulty = [standardUserDefaults integerForKey:kPuzzleDifficulty];
	saveCurrentDotImage = [standardUserDefaults integerForKey:kCurrentDotImage];
	saveDotDifficulty = [standardUserDefaults integerForKey:kDotDifficulty];
	introPresentationPlayed = [standardUserDefaults boolForKey:kIntroPresentationPlayed];
	swipeInReadIsTurnedOff = [standardUserDefaults boolForKey:kSwipeInReadIsTurnedOff];
    
    //if we are not coming from the background or runnging the app for the first time
    if (keepPrefs != YES && introPresentationPlayed != NO) {
        //reset app preferences
        saveSelectedAppSection = 2;
        saveLastVisitedMenuItem = 2;
        
        //iphone page 0 i more of a landing page
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            saveCurrentReadPage = 1;        
        }
        else {
            saveCurrentReadPage = 0;
        }
    }
}
-(void)savePrefs {
	//save prefs
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setInteger:saveSelectedAppSection forKey:kSelectedAppSection];
	[standardUserDefaults setInteger:saveLastVisitedMenuItem forKey:kLastVisitedMenuItem];
	[standardUserDefaults setInteger:saveCurrentReadPage forKey:kCurrentReadPage];
	[standardUserDefaults setBool:saveReadNarrationSetting forKey:kReadNarrationSetting];
	[standardUserDefaults setBool:saveReadEnlargeTextSetting forKey:kReadEnlargeTextSetting];
	[standardUserDefaults setBool:saveReadMusicSetting forKey:kReadMusicSetting];
	[standardUserDefaults setInteger:saveCurrentPaintImage forKey:kCurrentPaintImage];
	[standardUserDefaults setInteger:saveCurrentPaintBrush forKey:kCurrentBrushSize];
	[standardUserDefaults setInteger:saveCurrentPaintColor forKey:kCurrentPaintColor];
	[standardUserDefaults setInteger:saveCurrentPuzzle forKey:kCurrentPuzzle];
	[standardUserDefaults setInteger:savePuzzleDifficulty forKey:kPuzzleDifficulty];
	[standardUserDefaults setInteger:saveCurrentDotImage forKey:kCurrentDotImage];
	[standardUserDefaults setInteger:saveDotDifficulty forKey:kDotDifficulty];
	[standardUserDefaults setBool:introPresentationPlayed forKey:kIntroPresentationPlayed];
	[standardUserDefaults setBool:swipeInReadIsTurnedOff forKey:kSwipeInReadIsTurnedOff];
}

#pragma mark -
#pragma mark Project inits
-(void) setupRootViewController {
	//add root view controller
	myRootViewController = [[ThomasRootViewController alloc] initWithNibName:@"ThomasRootViewController" bundle:nil];
	[window addSubview:myRootViewController.view];
}
#pragma mark -
#pragma mark Getters and Setters
- (id)getCurrentLanguage {
	//NSLog(@"ASKING ABOUT LANGUAGE");
	NSLocale *currentUsersLocale = [NSLocale currentLocale];
	NSString *currentlanguage = [NSString stringWithFormat:@"%@", [currentUsersLocale localeIdentifier]];
	NSLog(@"This is the current language: %@", currentlanguage);
	if ([currentlanguage isEqualToString:@"haw_US"]) {
		NSLog(@"This is hawaiian");
		return currentlanguage;
	} else if ([currentlanguage isEqualToString:@"en_US"]) {
		//NSLog(@"I am in US");
		return currentlanguage;
	} else {
		//here we check for exceptions right?
		if ([self isLanguage:@"en"] && ([self isRegion:@"VI"] || [self isRegion:@"CA"] || [self isRegion:@"PH"])) {
			NSLog(@"The exception language's");
			currentlanguage = @"en_US";
			return currentlanguage;
		} else {
			NSLog(@"I am in the rest of the world"); // <-- If not in the exception list this app is going for UK English
			currentlanguage = @"en_GB";
			return currentlanguage;
		}
	}

}

+(NSString *) getLocalizedAssetName:(NSString*)assetname {
    //if in UK-area add _UK to soundfiles that have the _lang tag
    NSString *langadd = @"";
    Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
    if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"]) {
        langadd = @"_UK";
    }
    NSString *strippedname = [assetname stringByDeletingPathExtension];
    NSString *localizedname = [strippedname stringByAppendingString:langadd];
    NSString *assetextension = [assetname pathExtension];
    NSString *fixedname;
    //only append if we have an extenstion otherwise we will end upp with appending . to the string
    if ([assetextension length] == 0) {
        fixedname = localizedname;
    }
    else {
        fixedname = [localizedname stringByAppendingPathExtension:assetextension];
    }
    NSLog(@"This is the fixed path being returned: %@", fixedname);
    return fixedname;
}

#pragma mark -
#pragma mark LANGUAGE - Regional Override
- (bool)isLanguage:(NSString*)checkLanguage
{
    // Lookup app languages
    NSBundle* appBundle = [NSBundle mainBundle];
    NSArray*  appLanguages = [appBundle preferredLocalizations];
    if( [appLanguages count] > 0 )
    {
        NSString* appLang = [appLanguages objectAtIndex:0];
        // Convert both strings to lower case ready for compare
        NSString* lowercaseAppLang   = [appLang lowercaseString];
        NSString* lowercaseCheckLang = [checkLanguage lowercaseString];
		
        if( [lowercaseAppLang hasPrefix:lowercaseCheckLang ] )
        {
            return TRUE;
        }
    }
	
    // No match
	return FALSE;
}

- (bool)isRegion:(NSString*)checkRegion
{
    // Lookup current locale
    NSLocale* appLocale   = [NSLocale currentLocale];
    NSString* appLocaleId = [appLocale localeIdentifier];
	
    // Convert both strings to lower case ready for compare
    NSString* lowercaseAppLocale   = [appLocaleId lowercaseString];
    NSString* lowercaseCheckRegion = [checkRegion lowercaseString];
	
    // Matching region?
    if( [lowercaseAppLocale hasSuffix:lowercaseCheckRegion ] )
    {
        return TRUE;
    }
	
    // No match
	return FALSE;
}
#pragma mark -
#pragma mark GETTERS and SETTERS
-(int) getSaveSelectedAppSection {
	return saveSelectedAppSection;
}
-(void) setSaveSelectedAppSection:(int)value {
	NSLog(@"Saving with value: %i", value);
	saveSelectedAppSection = value;
	[self savePrefs];
}

-(int) getSaveLastVisitedMenuItem {
	return saveLastVisitedMenuItem;
}
-(void) setSaveLastVisitedMenuItem:(int)value {
	saveLastVisitedMenuItem = value;
	[self savePrefs];
}

-(BOOL)getSaveReadEnlargeTextSetting{
	return saveReadEnlargeTextSetting;
}


-(void)setSaveReadEnlargeTextSetting:(BOOL)value{
	saveReadEnlargeTextSetting=value;
	[self savePrefs];
}
-(int) getSaveCurrentReadPage {
	return saveCurrentReadPage;
}
-(void) setSaveCurrentReadPage:(int)value {
	saveCurrentReadPage = value;
	[self savePrefs];
}
-(BOOL) getSaveNarrationSetting {
	return saveReadNarrationSetting;
}
-(void) setSaveNarrationSetting:(BOOL)value {
	saveReadNarrationSetting = value;
	[self savePrefs];
}
-(BOOL) getSaveMusicSetting {
	return saveReadMusicSetting;
}
-(void) setSaveMusicSetting:(BOOL)value {
	saveReadMusicSetting = value;
	[self savePrefs];
	//play music
	if (value) {
		[self startReadPlayback];
	} else {
		[self pauseReadPlayback];
	}
}
-(int) getSaveCurrentPaintImage {
	return saveCurrentPaintImage;
}
-(void) setSaveCurrentPaintImage:(int)value {
	saveCurrentPaintImage = value;
	[self savePrefs];
}
-(int) getSaveCurrentPaintBrush {
	return saveCurrentPaintBrush;
}
-(void) setSaveCurrentPaintBrush:(int)value {
	saveCurrentPaintBrush = value;
	[self savePrefs];
}
-(int) getSaveCurrentPaintColor {
	return saveCurrentPaintColor;
}
-(void) setSaveCurrentPaintColor:(int)value {
	saveCurrentPaintColor = value;
	[self savePrefs];
}
-(int) getSaveCurrentPuzzle {
	return saveCurrentPuzzle;
}
-(void) setSaveCurrentPuzzle:(int)value {
	saveCurrentPuzzle = value;
	[self savePrefs];
}
-(int) getSaveCurrentPuzzleDifficulty {
	return savePuzzleDifficulty;
}
-(void) setSaveCurrentPuzzleDifficulty:(int)value {
	savePuzzleDifficulty = value;
	[self savePrefs];
}
-(int) getSaveCurrentDotImage {
	return saveCurrentDotImage;
}
-(void) setSaveCurrentDotImage:(int)value {
	saveCurrentDotImage = value;
	[self savePrefs];
}
-(int) getSaveDotDifficulty {
	return saveDotDifficulty;
}
-(void) setSaveDotDifficulty:(int)value {
	saveDotDifficulty = value;
	[self savePrefs];
}
-(BOOL) getIntroPresentationPlayed {
	return introPresentationPlayed;
}
-(void) setIntroPresentationPlayed:(BOOL)value {
	introPresentationPlayed = value;
	[self savePrefs];
}
-(NSTimeInterval)setNarrationTime:(NSTimeInterval) time {
	
	NSTimeInterval runningNarrationTime = time;
	
	//Save to prefs
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setInteger:runningNarrationTime forKey:kRunningNarrationTime];
	NSDate *now = [NSDate date];
	[standardUserDefaults setValue:now forKey:kOldSavedDate];
	
	return runningNarrationTime;
}
-(id)getNarrationTime {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSDate *old = [standardUserDefaults valueForKey:kOldSavedDate];
	return old;
}

-(void)setSavedDelaytime:(float)delay {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setFloat:delay forKey:kNarrationDelayTime];
}
-(float)getSavedDelaytime {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	float thetime = [standardUserDefaults floatForKey:kNarrationDelayTime];
	return thetime;
}

-(NSTimeInterval)setHotspotsTime:(NSTimeInterval) time {
	
	NSTimeInterval runningHotspotsTime = time;
	
	//Save to prefs
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setInteger:runningHotspotsTime forKey:kRunningHotspotsTime];
	NSDate *now = [NSDate date];
	[standardUserDefaults setValue:now forKey:kOldSavedHotspotsDate];
	
	return runningHotspotsTime;
}
-(id)getHotspotsTime {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSDate *old = [standardUserDefaults valueForKey:kOldSavedHotspotsDate];
	return old;
}
-(void)setSavedHotspotsDelaytime:(float)delay {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setFloat:delay forKey:kHotspotsDelayTime];
}
-(float)getSavedHotspotsDelaytime {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	float thetime = [standardUserDefaults floatForKey:kHotspotsDelayTime];
	return thetime;
}
-(BOOL)getReadViewIsPaused {
	return [[self currentRootViewController] getReadViewIsPaused];
}
-(BOOL)getSwipeInReadIsTurnedOff {
	return swipeInReadIsTurnedOff;
}
-(void)setSwipeInReadIsTurnedOff:(BOOL)value {
	swipeInReadIsTurnedOff = value;
	[self savePrefs];
}
/*
-(BOOL)getPuzzleDifficulty {
	return puzzleDifficulty;
}
 */

#pragma mark -
#pragma mark AudioSession methods

- (void)pauseReadPlayback
{
	//useBkgMusic = NO;
	[self.audioPlayer pause];
	//NSLog(@"Background music in Read was paused");
}

- (void)startReadPlayback
{
	//useBkgMusic = YES;
	//NSLog(@"Background music in Read was started");
	if ([self.audioPlayer play])
	{
		self.audioPlayer.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.audioPlayer.url);
}
- (void)startFXPlayback
{
	//NSLog(@"Read FX-sound was started");
	if ([self.fxPlayer play])
	{
		self.fxPlayer.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.fxPlayer.url);
}
- (void)stopFXPlayback
{
	//NSLog(@"Got a stop playing for the fx - and then a crash?");
	if (self.fxPlayer != nil && self.fxPlayer.playing) {
		[self.fxPlayer stop];
		//NSLog(@"FX-sound Read was paused");
	}
}
- (void) startReadSpeakerPlayback {
	if ([[self currentRootViewController] getCurrentNavigationItem] != 3) return;
	//NSLog(@"Read speaker was started");
	if (saveReadNarrationSetting) {
		if ([self.speakerPlayer play])
		{
			self.speakerPlayer.delegate = self;
		}
		else {
			NSLog(@"Could not play %@\n", self.speakerPlayer.url);
		}
	}
}

- (void) forceReadSpeakerPlayback {
	if ([[self currentRootViewController] getCurrentNavigationItem] != 3) return;
	//NSLog(@"Read speaker was started");
		if ([self.speakerPlayer play])
		{
			self.speakerPlayer.delegate = self;
		}
		else {
			NSLog(@"Could not play %@\n", self.speakerPlayer.url);
		}
}
- (void) pauseReadSpeakerPlayback {
	//NSLog(@"Read speaker was Paused");
	//if (saveReadNarrationSetting) {
		[self.speakerPlayer pause];
	[[self currentRootViewController] setSpeakerIsPaused:YES];
	//[myRootViewController narrationFinished];
	//}
}
- (void) pauseByFXReadSpeakerPlayback {
	//NSLog(@"Read speaker was Paused");
	//if (saveReadNarrationSetting) {
	[self.speakerPlayer pause];
	[[self currentRootViewController] setSpeakerIsPausedByFX:YES];
	[[self currentRootViewController] narrationFinished];
	//}
}
-(void) stopReadSpeakerPlayback {
	//NSLog(@"Read speaker was Stopped");
	if (self.speakerPlayer != nil && self.speakerPlayer.playing) {
		[self.speakerPlayer stop];
		[[self currentRootViewController] setSpeakerIsPaused:NO];
		[[self currentRootViewController] setSpeakerIsPausedByFX:NO];
		[[self currentRootViewController] narrationFinished];
	}
	//NSLog(@"Speaker in Read was paused");
}
-(void) cleanUpReadSpeaker {
	//[speakerPlayer release];
	[self.speakerPlayer stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	//NSLog(@"So audio got a didfinish playing here");
	if (player == self.audioPlayer) {
		if (flag == NO)
			//NSLog(@"Playback finished unsuccessfully");
			[player setCurrentTime:0.];
		[self startReadPlayback];
	} else if (player == self.speakerPlayer) {
		[[self currentRootViewController] narrationFinished];
	}
}
- (void) startInterfaceAudio {
	//NSLog(@"Interface audio was started");
	if ([self.interfaceSounds play])
	{
		self.interfaceSounds.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.interfaceSounds.url);
}
- (void) stopInterfaceAudio {
	if (self.interfaceSounds != nil && self.interfaceSounds.playing) {
		[self.interfaceSounds stop];
	}
	NSLog(@"interfaceSounds was paused");
}
- (void) startIntroPresentation {
	//NSLog(@"introPresentation audio was started");
	if ([self.introPresentation play])
	{
		self.introPresentation.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.introPresentation.url);
}
- (void) stopIntroPresentation {
	if (self.introPresentation != nil && self.introPresentation.playing) {
		[self.introPresentation stop];
	}
	NSLog(@"introPresentation was stopped");
}
- (void) startEndSound {
	//NSLog(@"endsound audio was started");
	if ([self.endSound play])
	{
		self.endSound.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.endSound.url);
}
- (void) stopEndSound {
	if (self.endSound != nil && self.endSound.playing) {
		[self.endSound stop];
	}
	NSLog(@"endsound was stopped");
}
#pragma mark soundfx
- (void)playFXEventSound:(NSString *)sound {
	if (self.interfaceSounds.playing) [self stopInterfaceAudio];
	
	NSURL *fileURL;
	if ([sound isEqualToString:@"Select"]) {
		//Play sound
		//[selectSound play];
		NSString *mypath = [NSString stringWithFormat:@"select"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else if ([sound isEqualToString:@"Menu"]) {
		//play sound
		//[menusound play];
		NSString *mypath = [NSString stringWithFormat:@"menu"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else if ([sound isEqualToString:@"mainmenu"]) {
		//play sound
		//[menusound play];
		NSString *mypath = [NSString stringWithFormat:@"menu_bar"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"wav"]];
	} else if ([sound isEqualToString:@"endsound"]) {
		//play sound
		//[menusound play];
		NSString *mypath = [NSString stringWithFormat:@"end_sound"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else if ([sound isEqualToString:@"match"]) {
		//play sound
		NSString *mypath = [NSString stringWithFormat:@"thomas_interactive_scene17"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else if ([sound isEqualToString:@"matchpayoff"]) {
		//play sound
		NSString *langadd = @"";
		if ([[self getCurrentLanguage] isEqualToString:@"en_GB"]) {
			langadd = @"_UK";
		}
		NSString *mypath = [NSString stringWithFormat:@"matchpayoffsound%@", langadd];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else {
		//Play sound
		//[erasingSound play];
		NSString *mypath = [NSString stringWithFormat:@"erase"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	}

	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.interfaceSounds = thePlayer;
		[thePlayer release];
		self.interfaceSounds.volume = 1.0;
		[self startInterfaceAudio];
	}
}
- (void)playCardSound:(int)sound {
	if (self.interfaceSounds.playing) [self stopInterfaceAudio];
	NSString *langadd = @"";
	if (sound-1 == 4 || sound-1 == 1 || sound-1 == 0) {
		if ([[self getCurrentLanguage] isEqualToString:@"en_GB"]) {
			langadd = @"_UK";
		}
	}
	NSString *mypath = [NSString stringWithFormat:@"cardsound%i" "%@", sound-1, langadd];
	NSLog(@"this is the uk-path for cardsound: %@", mypath);
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.interfaceSounds = thePlayer;
		[thePlayer release];
		self.interfaceSounds.volume = 1.0;
		[self startInterfaceAudio];
	}
}
#pragma mark introPresentation
-(void)playintroPresentation {
	NSString *mypath = [NSString stringWithFormat:@"intro_presentation"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.introPresentation = thePlayer;
		[thePlayer release];
		self.introPresentation.volume = 1.0;
		[self startIntroPresentation];
	}
}
#pragma mark music in read 
-(void)loadReadMusic {
	NSString *mypath = [NSString stringWithFormat:@"read_music"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.audioPlayer = thePlayer;
		[thePlayer release];
		self.audioPlayer.volume = 1.0;
		[self startReadPlayback];
	}
}
#pragma mark endsound
-(void)playEndSound {
	NSString *mypath = [NSString stringWithFormat:@"end_sound"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.endSound = thePlayer;
		[thePlayer release];
		self.endSound.volume = 1.0;
		[self startEndSound];
	}
}
-(void)unloadReadMusic {
	//if (player == self.audioPlayer) {
	if (self.audioPlayer != nil && self.audioPlayer.playing) {
		[self.audioPlayer stop];
		[self.audioPlayer release];
	}
}
#pragma mark -
#pragma mark RootViewController Relays
-(void)videoFinishedPlaying {
	[[self currentRootViewController] videoFinishedPlaying];
}
-(void)introFinishedPlaying {
	[[self currentRootViewController] introFinishedPlaying];
}
-(void)showFakeLandingPage {
	[[self currentRootViewController] showFakeLandingPage];
}
-(void)unPauseReadView {
	[[self currentRootViewController] unPauseReadView];
}
#pragma mark -
#pragma mark application related
- (void)applicationWillResignActive:(UIApplication *)application {
	//NSLog(@"applicationWillResignActive");
	/*
	[[self currentRootViewController] unloadCurrentNavigationItem];
	
	[[self currentRootViewController] removePendingSceneDelay];
	[[self currentRootViewController] removePendingHotspotsDelay];
	
	
	if ([[self currentRootViewController] getCurrentNavigationItem] == 3) {
		[self stopReadSpeakerPlayback];
		[[self currentRootViewController] pauseCocos];
	}
	 
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];*/
	//sectionWeLeft = [[self currentRootViewController] getCurrentNavigationItem];
	if ([[self currentRootViewController] getCurrentNavigationItem] == 3) {
		[self stopReadSpeakerPlayback];
		[[self currentRootViewController] pauseCocos];
	}
    
    keepPrefs = YES;

	[self savePrefs];
	//[[self currentRootViewController] navigateFromMainMenuWithItem:0];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	//NSLog(@"applicationDidBecomeActive - within the current section: %i", [[self currentRootViewController] getCurrentNavigationItem]);
	/*
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] resumeCocos];
	}
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];
	*/
	/*
	if (saveReadMusicSetting && [[self currentRootViewController] getCurrentNavigationItem]==3) {
		[self startReadPlayback];
	}
	 */
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] resumeCocos];
	}
	[self loadPrefs];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	//NSLog(@"applicationWillTerminate");
	
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] killCocos];
	}
	/*
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];
	*/
	[self savePrefs];
    
    [UAirship land];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	//NSLog(@"applicationDidEnterBackground");
	
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[self stopReadSpeakerPlayback];
		[[self currentRootViewController] stopCocos];
	}
	/*
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];
	[[self currentRootViewController] narrationFinished];
	*/
    keepPrefs = YES;
    
	[self savePrefs];
	[[self currentRootViewController] navigateFromMainMenuWithItem:0];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	//NSLog(@"applicationWillEnterForeground - within the current section: %i", [[self currentRootViewController] getCurrentNavigationItem]);
	/*
	[[self currentRootViewController] navigateFromMainMenuWithItem:saveSelectedAppSection];
	
	
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] startCocos];
	}
	
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];
	 */
	//NSString *lang = [self getCurrentLanguage];
	//NSLog(@"getting language on enter: %@", lang);
	[self loadPrefs];
	[[self currentRootViewController] navigateFromMainMenuWithItem:saveSelectedAppSection];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	//NSLog(@"applicationSignificantTimeChange");
	/*
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] resetCocos];
	}
	 */
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
	//audio
	[audioPlayer release];
	[fxPlayer release];
	[speakerPlayer release];
	[interfaceSounds release];
	[endSound release];
	//TEMP to fix
	[currentPaintImage release];
	[myRootViewController release];
	//
    [super dealloc];
}

#pragma mark universal getters
-(ThomasRootViewController *)currentRootViewController{
	return myRootViewController;
}

+(Misty_Island_Rescue_iPadAppDelegate *)get{
	return (Misty_Island_Rescue_iPadAppDelegate *)[[UIApplication sharedApplication]delegate];
}
@end
