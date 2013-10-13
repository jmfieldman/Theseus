//
//  TheseusAppDelegate.m
//  Theseus
//
//  Created by Jason Fieldman on 12/23/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "TheseusAppDelegate.h"
#import "DungeonViewController.h"
#import "MainMenuViewController.h"
#import "FlourishController.h"
#import "TileHelper.h"
#import "SoundManager.h"
#import "GameStateModel.h"
#import "MapGenerator.h"
#import "MapModel.h"

#import "Flurry.h"

@implementation TheseusAppDelegate

@synthesize window;

- (void)_generateSolutionDump {
	int best_solutions[NUM_LEVELS];
	for (int level = 0; level < NUM_LEVELS; level++) {
		MapModel *map = [MapGenerator getMap:level];
		[map createSolveMap];
		int cur = [map getCurrentPosSolve];
		best_solutions[level] = (cur & 0xFF);
		NSLog(@"best for level %d: %d", level, best_solutions[level]);
		[map cleanSolveMap];
	}
	
	for (int i = 0; i < NUM_LEVELS; i++) {
	//	NSLog(@"best for level %d: %d", i, best_solutions[i]);
	}
	
	exit(0);
}

void uncaughtExceptionHandler(NSException *exception) {
	[Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[Flurry startSession:@"YTCADT3LIDMKBGT7WKTQ"];
	[Globals initGlobals];
	InitializeTiles();
	[SoundManager initialize];
	[GameStateModel CreateGameStateFileIfNecessary];
	[GameStateModel LoadGameState];
	srand(time(0));
	
	if (![GameStateModel getIdleTimer]) [UIApplication sharedApplication].idleTimerDisabled = YES;
	
//#define GENERATE_SOLUTION_DUMP
#ifdef GENERATE_SOLUTION_DUMP
	[self _generateSolutionDump];
#endif
		
	/* Do some pre-init of the classes */
	[MainMenuViewController sharedInstance];
	[DungeonViewController sharedInstance];
	
	window.backgroundColor = [UIColor blackColor];
	
	//[window addSubview:[DungeonViewController sharedInstance].view];
	CGRect f = window.frame;
	f.size.height = [UIScreen mainScreen].bounds.size.height;
	window.frame = f;
	
	[window addSubview:[FlourishController sharedInstance].view];
	//window.rootViewController = [FlourishController sharedInstance];
	
	/* Load into the puzzle if we left off there.. */
	int saved_level = [GameStateModel getCurrentLevel];
	if (saved_level >= 0) {
		[GameStateModel fillHistory];		
		[[FlourishController sharedInstance] transitionToDungeon:saved_level];
	} else {
		[[FlourishController sharedInstance] transitionToMenu];
	}
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[GameStateModel SaveGameState];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[GameStateModel SaveGameState];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
