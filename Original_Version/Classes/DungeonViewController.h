//
//  DungeonViewController.h
//  Theseus
//
//  Created by Jason Fieldman on 8/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStructures.h"
#import "MapModel.h"
#import "MapView.h"
#import "DungeonNavigationView.h"
#import "GameMenuView.h"

#define MINO_STEP_DELAY_FAST   0.05
#define MINO_STEP_DELAY_NORMAL 0.19

/* Tutorial state machine */
#define TUTORIAL_L1_WELCOME       1
#define TUTORiAL_L1_CHECKHOWTO    2
#define TUTORIAL_L1_HOWTOMOVE     3
#define TUTORIAL_L1_GOODJOB       4
#define TUTORIAL_L1_EXPLAIN       5

#define TUTORIAL_L2_UPPERRIGHT    1
#define TUTORIAL_L2_LOWERRIGHT    2
#define TUTORIAL_L2_AHHA          3

#define TUTORIAL_L3_NEEDTOTRAP    1
#define TUTORIAL_L3_NEEDTOWAIT    2
#define TUTORIAL_L3_NEAREXIT      3
#define TUTORIAL_L3_NEAREXIT2     4


@interface DungeonViewController : UIViewController <DungeonNavigationDelegate> {

	/* Map model */
	MapModel *map_model;
	int my_level;
	
	/* Map View */
	MapView *map_view;
	
	/* Navigation View */
	DungeonNavigationView *nav_view;
	
	/* Game Menu View */
	GameMenuView *game_menu_view;
	
	/* Minotaur steps */
	int mino_steps_remaining;
	
	/* Alert for leaving the game */
	UIAlertView *reset_alert;
	UIAlertView *exit_alert;
	UIAlertView *win_alert;
	UIAlertView *nomoremaps_alert;
		
	/* Tutorial */
	UIAlertView *tutorial_alert;
	int tutorial_step;
	
	/* Titlebar features */
	UILabel *levelTitle;
	UIButton *exitButton;
	UIButton *resetButton;
	UIImageView *award_pic;
}

- (void)acceptNavigation:(DungeonNavigationOptions_t)option;
- (void)initializeForLevel:(int)level;
- (void)updateURM;
- (void)setNoTutorial;

@property (readonly) int my_level;
@property (readonly) MapModel *map_model;

@end
