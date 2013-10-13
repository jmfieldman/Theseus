//
//  DungeonViewController.m
//  Theseus
//
//  Created by Jason Fieldman on 8/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DungeonViewController.h"
#import "MapModel.h"
#import "MapView.h"
#import "MapGenerator.h"
#import "DungeonNavigationView.h"
#import "Sound.h"
#import "GameStateModel.h"
#import "MainMenuViewController.h"
#import "NavigationHelperModel.h"

@implementation DungeonViewController
@synthesize my_level;
@synthesize map_model;

- (id)init {
	self = [super init];
	if (self) {
		mino_steps_remaining = 0;
		
		reset_alert = nil;
		exit_alert = nil;
		win_alert = nil;
		
		/* Tutorial */
		tutorial_alert = nil;
		
		my_level = -1;
	}	
	return self;
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,20,320,460)];
	contentView.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1];
	//contentView.backgroundColor = [UIColor blackColor];
	self.view = contentView;
	[contentView release];
	
	UIImageView *bck_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	bck_view.image = img_dun_bk;
	[contentView addSubview:bck_view];
	
	map_model = [MapGenerator getMap:1];
	//map_view = [[MapView alloc] initWithFrame:CGRectMake(20,20,292,184) withMap:map_model withBorder:20];
	//map_view = [[MapView alloc] initWithFrame:CGRectMake(20,20,252,144) withMap:map_model withBorder:0];
	map_view = [[MapView alloc] initWithFrame:CGRectMake(20,20,56,32) withMap:map_model withBorder:0];
	nav_view = [[DungeonNavigationView alloc] initWithFrame:CGRectMake(0, 320, 320, 140) withMap:map_model];
	nav_view.backgroundColor = [UIColor clearColor];
	
	game_menu_view = [[GameMenuView alloc] initWithFrame:CGRectMake(0, 294, 320, 166)];
	game_menu_view.backgroundColor = [UIColor clearColor];
	
	map_view.navDelegate = self;
	map_view.multipleTouchEnabled = YES;
	nav_view.navDelegate = self;
	game_menu_view.navDelegate = self;
	
	//[map_view setPreviewMode:YES];
	[contentView addSubview:map_view];
	[contentView addSubview:nav_view];
	[contentView addSubview:game_menu_view];
	
	exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	exitButton.frame = CGRectMake(0,0,40,40);
	exitButton.backgroundColor = [UIColor clearColor];
	[exitButton setBackgroundImage:img_close_button forState:UIControlStateNormal];	
	[exitButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:exitButton];
	
	resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
	resetButton.frame = CGRectMake(280,0,40,40);
	resetButton.backgroundColor = [UIColor clearColor];
	[resetButton setBackgroundImage:img_reload forState:UIControlStateNormal];	
	[resetButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:resetButton];
	
	levelTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 1, 200, 19)];
	levelTitle.backgroundColor = [UIColor clearColor];
	levelTitle.text = [NSString stringWithFormat:@"Level 1"];
	levelTitle.textColor = [UIColor blackColor];
	levelTitle.font = sys16;
	levelTitle.textAlignment = UITextAlignmentCenter;
	[contentView addSubview:levelTitle];
	
	award_pic = [[UIImageView alloc] initWithFrame:CGRectMake(200, 1, 20, 20)];
	award_pic.backgroundColor = [UIColor clearColor];
	[contentView addSubview:award_pic];
}

- (void)initializeForLevel:(int)level {
	tutorial_step = 0;
	my_level = level;
	map_model = [MapGenerator getMap:level];
	
	if ([GameStateModel getLevelCompleted:level]) {
		levelTitle.textColor = [UIColor colorWithRed:0 green:0.9 blue:0 alpha:1];
		levelTitle.text = [NSString stringWithFormat:@"Level %s - Completed", display_names[level]];
	} else {
		levelTitle.textColor = [UIColor blackColor];
		levelTitle.text = [NSString stringWithFormat:@"Level %s", display_names[level]];
	}
	
	int tl = [levelTitle.text sizeWithFont:sys16].width;
	int b = [GameStateModel getLevelBadge:level];
	if (b) {
		award_pic.image = img_badges[b-1];
		award_pic.hidden = NO;
		
		CGRect f = award_pic.frame;
		f.origin.x = (320+tl)/2;
		award_pic.frame = f;
	} else {
		award_pic.hidden = YES;
	}
	
	int border = 20;
	if (map_model.size.w > 9) border = 10;
	int sw = 280;
	if (map_model.size.w > map_model.size.h) sw = 300;
	int tilesize_w = (sw-border*2) / map_model.size.w;
	int tilesize_h = (sw-border*2) / map_model.size.h;
	int tilesize = (tilesize_w < tilesize_h) ? tilesize_w : tilesize_h;
	if (tilesize > 50) tilesize = 50;
	
	int w = (map_model.size.w * tilesize) + border * 2;
	int h = (map_model.size.h * tilesize) + border * 2;
	
	int fx = 160 - (w/2);
	int fy = 165 - (h/2);
	
	[map_view updateWithFrame:CGRectMake(fx,fy,w,h) withMap:map_model withBorder:border];
	[nav_view updateWithMap:map_model];
	[nav_view setNeedsDisplay];
	[map_view setNeedsDisplay];
	
	PlayEnter();
}

- (void)updateURM {
	[nav_view updateURM];
}

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */

- (void)viewWillAppear:(BOOL)animated {
	[game_menu_view showMenu:NO];
}

- (void)handleTutorialEntry {
	if (tutorial_step == -1000) return;
	if (my_level == 0) {
		tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Welcome to the first level of Theseus and the Minotaur.  You can stop this tutorial at any time by selecting 'Skip Tutorial'."
												   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"Next", nil];
		[tutorial_alert show];
		tutorial_step = TUTORiAL_L1_CHECKHOWTO;
	}
	if (my_level == 1) {
		tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Let's trap the minotaur again.  Go right as far as you can, then go up once."
												   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"Next", nil];
		[tutorial_alert show];
		tutorial_step = TUTORIAL_L2_UPPERRIGHT;
	}
	if (my_level == 2) {
		tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"It's not good enough just to reach the stairs.  You must reach the stairs without the minotaur catching you in the same turn.  If you try to take a step to the right, you'll see."
												   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"Next", nil];
		[tutorial_alert show];
		tutorial_step = TUTORIAL_L3_NEEDTOTRAP;
	}
}

- (void)setNoTutorial {
	tutorial_step = -1000;
}

- (void)viewDidAppear:(BOOL)animated {	
	[self handleTutorialEntry];
}

- (void)viewWillDisappear:(BOOL)animated {
	[game_menu_view showMenu:NO];
}

- (void)quittingLevel {
	[map_model resetMap];
	my_level = -1;
	[GameStateModel SaveGameState];
}

- (void)buttonAction:(id)sender {
	if (sender == exitButton) {
		[self acceptNavigation:DNAV_EXIT_TO_MAIN];
	}
	if (sender == resetButton) {
		[self acceptNavigation:DNAV_RESET_LEVEL];
	}
}

- (void)handleCaught {
	PlayCaught();
}

- (void)handleWin {
	PlayCrowd();
	[GameStateModel setLevelCompleted:my_level];
	
	/* Handle badge */
	if (map_model.history_cursor <= map_model.best_move_pos) {
		[GameStateModel setBadge:3 forLevel:my_level];
	} else {
		[GameStateModel setBadge:2 forLevel:my_level];
	}
	
	MainMenuViewController *main = GetMainMenuViewController();
	[main redrawCell:my_level];
	win_alert = [[UIAlertView alloc] initWithTitle:@"You have escaped.. for now!" message:@"You have successfully evaded the minotaur and escaped from certain death.  But the minotaur follows you to the next level.."
										   delegate:self cancelButtonTitle:@"Proceed Valiantly" otherButtonTitles:nil];
	[win_alert show];
}

- (void)handleSnapshot {
	BOOL endofrope = [map_model snapshotForHistory];
	[nav_view updateURM];
	if (endofrope) {
		
	}
}

- (void)handleTimer:(NSTimer*)theTime {
	[map_view setNeedsDisplay];
	[nav_view setNeedsDisplay];
	
	if ([map_model minotaurWillMove] == DIR_WAIT) {
		[theTime invalidate];
		mino_steps_remaining = 0;
		if ([map_model hasTheseusExit]) {
			[self handleWin];
		}
		return;
	}
	
	[map_model moveMinotaur];	
	
	if ([map_model isTheseusDead])
		[self handleCaught];
	else
		PlayStomp();
	
	mino_steps_remaining--;
	
	if (mino_steps_remaining == 0 || [map_model minotaurWillMove] == DIR_WAIT) {
		[theTime invalidate];		
		mino_steps_remaining = 0;
		[self handleSnapshot];
		if (![map_model isTheseusDead] && [map_model hasTheseusExit]) {
			[self handleWin];
		}
	}
}

- (void)acceptNavigation:(DungeonNavigationOptions_t)option {
	switch (option) {
		case DNAV_MOVE_N:
		case DNAV_MOVE_E:
		case DNAV_MOVE_W:
		case DNAV_MOVE_S:
		case DNAV_WAIT:
			
			if (mino_steps_remaining > 0 || [map_model isTheseusDead])
				break;
			
			if (![map_model canTheseusMove:option]) {
				break;
			}
			
			if (option == DNAV_WAIT && ![map_model minotaurWillMove]) {
				break;
			}
			
			[map_model moveTheseus:option];
			
			/* Handle tutorial messages */
			if (tutorial_step > 0) {
				if (my_level == 0) {
					if (tutorial_step == TUTORIAL_L1_GOODJOB && map_model.theseus.x == 0 && map_model.theseus.y == 2) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Remember that to get closer to you, the minotaur will always try to move horizontally first.  You can use that to your advantage by moving to the right."
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
						tutorial_step = TUTORIAL_L1_EXPLAIN;
					}
					if (tutorial_step == TUTORIAL_L1_GOODJOB && map_model.theseus.x == 2 && map_model.theseus.y == 2) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"No, your other left!  It's too late now.  If you move left from here, the minotaur will walk down (since there is currently a wall to his left) and then move left to eat you.  You should undo your last move."
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
						//tutorial_step = TUTORIAL_L1_EXPLAIN;
					}
					if (tutorial_step == TUTORIAL_L1_EXPLAIN && map_model.theseus.x == 1 && map_model.theseus.y == 2) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Excellent, you have led the minotaur into a trap!  Remember that he will never walk away from you, so you can now escape to the stairs."
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
						tutorial_step = -1;
					}
				} else if (my_level == 1) {
					if (tutorial_step == TUTORIAL_L2_UPPERRIGHT && map_model.theseus.x == 6 && map_model.theseus.y == 0) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Uh oh, the minotaur will now come charging to the right.  Let's trap him by moving three spaces down, then one to the left."
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
						tutorial_step = TUTORIAL_L2_LOWERRIGHT;
					}
					if (tutorial_step == TUTORIAL_L2_LOWERRIGHT && map_model.theseus.x == 6 && map_model.theseus.y == 3) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"It is important to remember that, if he can, the minotaur will always try to move horizontally first for each step it takes.  Move left to trap him!"
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
						tutorial_step = TUTORIAL_L2_AHHA;
					}
					if (tutorial_step == TUTORIAL_L2_AHHA && map_model.theseus.x == 5 && map_model.theseus.y == 3) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Now that the minotaur is trapped in his nook, you can safely move to the exit."
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
						tutorial_step = -1;
					}
				} else if (my_level == 2) {
					if (tutorial_step == TUTORIAL_L3_NEEDTOWAIT && map_model.theseus.x == 2 && map_model.theseus.y == 1) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Ouch, you'll want to undo that move."
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
					}
					if (tutorial_step == TUTORIAL_L3_NEEDTOWAIT && map_model.theseus.x == 0 && map_model.theseus.y == 3 && map_model.minotaur.y == 0) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Remember to use the wait command here to lure the minotaur one more step into the nook.  By waiting, the minotaur will get his two moves without requiring you to change positions."
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
					}
					if (tutorial_step == TUTORIAL_L3_NEEDTOWAIT && map_model.theseus.x == 0 && map_model.theseus.y == 3 && map_model.minotaur.y == 1) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Excellent!  The minotaur will now be delayed long enough for you to escape.  Move right twice then move up twice."
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
						tutorial_step = TUTORIAL_L3_NEAREXIT;
					}
					if (tutorial_step == TUTORIAL_L3_NEAREXIT && map_model.theseus.x == 2 && map_model.theseus.y == 2) {
						tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Since the monitaur is far enough away, you can step into the exit without him catching you this turn."
																   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
						[tutorial_alert show];
						tutorial_step = TUTORIAL_L3_NEAREXIT2;
					}
				}
			}
			/* End tutorial messages */
			
			if ([map_model minotaurWillMove] != DIR_WAIT) {
				mino_steps_remaining = 2;
				NSTimer *tmpTimer = [NSTimer scheduledTimerWithTimeInterval:(GlobalFastMinotaur() ? MINO_STEP_DELAY_FAST : MINO_STEP_DELAY_NORMAL) target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
				if (option == DNAV_WAIT) {
					[tmpTimer fire];
				}
			} else {
				[self handleSnapshot];
				if (![map_model isTheseusDead] && [map_model hasTheseusExit]) {
					[self handleWin];
				}
			}
			
			if ([map_model isTheseusDead]) {
				[self handleCaught];
			}
			break;
		
		case DNAV_UNDO:
			if (![map_model canUndo]) break;
			[map_model undo];
			[map_view setNeedsDisplay];
			[nav_view updateURM];
			[nav_view setNeedsDisplay];
			PlayBwah();
			break;
			
		case DNAV_REDO:
			if (![map_model canRedo]) break;
			[map_model redo];
			[map_view setNeedsDisplay];
			[nav_view updateURM];
			[nav_view setNeedsDisplay];
			PlayBwah();
			break;

		case DNAV_GAME_MENU:
			[game_menu_view showMenu:YES];
			break;
			
		case DNAV_RESET_LEVEL:
			/* Reset level instead of popup */
			[map_model resetMap];
			[self initializeForLevel:my_level];
			[game_menu_view showMenu:NO];			
			/*
			reset_alert = [[UIAlertView alloc] initWithTitle:@"Reset Level?" message:@"Do you really want to reset the level?"
												   delegate:self cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
			[reset_alert show];
			*/
			break;
			
		case DNAV_EXIT_TO_MAIN:
			/* Remove exit level check - now we just quit to the menu */
			{ 
				MainMenuViewController *mmvc = GetMainMenuViewController();
				[mmvc scrollToLevel:my_level]; 
			}
			[self quittingLevel];
			[[self navigationController] popViewControllerAnimated:YES];
			/*
			exit_alert = [[UIAlertView alloc] initWithTitle:@"Exit to Main Menu?" message:@"Do you really want to exit to the main menu?"
												   delegate:self cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
			[exit_alert show];
			*/
			break;
	}
	[map_view setNeedsDisplay];
	[nav_view setNeedsDisplay];
}

- (void)viewDidDisappear:(BOOL)animated {
	//[self quittingLevel];	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[alertView release];
	if (alertView == exit_alert && buttonIndex == 0) {
		[self quittingLevel];
		[[self navigationController] popViewControllerAnimated:YES];
		exit_alert = nil;
	}
	if (alertView == reset_alert && buttonIndex == 0) {
		[map_model resetMap];
		[self initializeForLevel:my_level];
		[game_menu_view showMenu:NO];
		reset_alert = nil;
	}
	if (alertView == win_alert) {
		[map_model resetMap];
		
		int nextLev = (my_level + 1) % NUM_LEVELS; //[GameStateModel getNextIncompleteLevelAfter:my_level];
		if (nextLev == my_level) {
			win_alert = nil;
			[self initializeForLevel:my_level];
			nomoremaps_alert = [[UIAlertView alloc] initWithTitle:@"You Have Triumphed!" message:@"You have escaped from every level in the labyrinth.  But our princess is in another castle..."
												   delegate:self cancelButtonTitle:@"I Am Awesome!" otherButtonTitles: nil];
			[nomoremaps_alert show];
			[[self navigationController] popViewControllerAnimated:YES];
			return;
		}
		
		[self initializeForLevel:nextLev];
		[self handleTutorialEntry];
		win_alert = nil;
	}
	if (alertView == tutorial_alert) {
		tutorial_alert = nil;
		if (buttonIndex == 0) {
			tutorial_step = -1;
			return;
		}
		if (my_level == 0) {
			if (tutorial_step == TUTORiAL_L1_CHECKHOWTO) {
				tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"If you haven't done so already, you are encouraged to exit to the main menu and click on the 'How To Play' button for complete instructions."
														   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"Next", nil];
				[tutorial_alert show];
				tutorial_step = TUTORIAL_L1_HOWTOMOVE;
			} else if (tutorial_step == TUTORIAL_L1_HOWTOMOVE) {
				tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"To begin, take a step to the left.  The minotaur will follow you left one step, then take one step downwards."
														   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"OK", nil];
				[tutorial_alert show];
				tutorial_step = TUTORIAL_L1_GOODJOB;
			}
		} else if (my_level == 2) {
			if (tutorial_step == TUTORIAL_L3_NEEDTOTRAP) {
				//tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"You'll need to delay the minotaur so that you have enough time to escape.  Move down twice, then once to the left."
				tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"Sometimes Theseus has to wait to give the Minotaur time to fall into a trap. Move down twice, then once to the left, then press Wait."
														   delegate:self cancelButtonTitle:@"Skip Tutorial" otherButtonTitles:@"Next", nil];
				[tutorial_alert show];
				tutorial_step = TUTORIAL_L3_NEEDTOWAIT;
			}
			if (tutorial_step == TUTORIAL_L3_NEAREXIT2) {
				tutorial_alert = [[UIAlertView alloc] initWithTitle:@"Tutorial" message:@"This concludes the tutorial, so you're on your own now.  Can you conquer every level of the labyrinth?"
														   delegate:self cancelButtonTitle:@"Cower In Fear" otherButtonTitles:@"Yes!", nil];
				[tutorial_alert show];
				tutorial_step = -1;
			}
		}
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end
