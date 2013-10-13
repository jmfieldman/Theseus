//
//  DungeonViewController.h
//  Theseus
//
//  Created by Jason Fieldman on 12/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapView.h"
#import "NavigationControlView.h"
#import "StatusBarView.h"
#import "CompletionSummary.h"
#import "TutorialView.h"
#import "OptionsView.h"

#define kNavConViewYCoord 340.0
#define kNavConViewHeight 120.0

@interface DungeonViewController : UIViewController <DungeonNavigationDelegate, OptionsDelegate> {
	UIView *contentView;
	
	/* Map View */
	MapView *map_view;
	
	/* Map Model */
	MapModel *map_model;
	
	/* Navigation Control Panel */
	NavigationControlView *nav_view;
	
	/* Status bar view */
	StatusBarView *status_view;
	
	/* Minotaur steps */
	int mino_steps_remaining;

	/* Display state */
	BOOL playing_level;
	
	/* Flourish State */
	BOOL flourished_in;
	
	/* Completion Window */
	CompletionSummary *comp_view;
	
	/* Options */
	OptionsView *opt_view;
	
	/* Tutorial */
	TutorialView *tutorial_view;
}

@property (readonly) MapView *map_view;
@property (readonly) MapModel *map_model;
@property (readonly) BOOL     playing_level;

+ (DungeonViewController*)sharedInstance;

- (void)acceptNavigation:(DungeonNavigationOptions_t)option;
- (void)acceptOptionsChange:(Options_t)option newValue:(BOOL)value;

- (void)flourishIn:(int)level;
- (void)flourishTo:(int)level;
- (void)flourishOut;

@end
