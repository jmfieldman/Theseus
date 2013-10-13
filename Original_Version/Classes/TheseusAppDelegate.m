//
//  TheseusAppDelegate.m
//  Theseus
//
//  Created by Jason Fieldman on 8/25/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "TheseusAppDelegate.h"
#import "MapGenerator.h"
#import "DungeonViewController.h"
#import "GraphicsModel.h"
#import "Sound.h"
#import "MainMenuViewController.h"
#import "GameStateModel.h"

@implementation TheseusAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	[MapGenerator initLevels];
	InitImgs();
	InitSound();
	[GameStateModel CreateGameStateFileIfNecessary];
	[GameStateModel LoadGameState];
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:GetMainMenuViewController()];
	[navigationController setNavigationBarHidden:YES];
	[window addSubview:navigationController.view];
	
	/* Load into the puzzle if we left off there.. */
	int saved_level = [GameStateModel getCurrentLevel];
	if (saved_level >= 0) {
		DungeonViewController *dvc = GetDungeonViewController();
		[navigationController pushViewController:dvc animated:YES];
		[dvc initializeForLevel:saved_level];
		[GameStateModel fillHistory];
		[dvc updateURM];
		[dvc setNoTutorial];
	}
	
	//DungeonViewController *dvc = [[DungeonViewController alloc] init];
	//[window addSubview:dvc.view];
	
	// Override point for customization after app launch	
    [window makeKeyAndVisible];
	[window setNeedsDisplay];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[GameStateModel SaveGameState];
}

- (void)dealloc {
	[window release];
	[super dealloc];
}


@end
