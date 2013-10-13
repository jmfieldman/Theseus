//
//  DungeonViewController.m
//  Theseus
//
//  Created by Jason Fieldman on 12/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DungeonViewController.h"
#import "MainMenuViewController.h"
#import "MapGenerator.h"
#import "SoundManager.h"
#import "FlourishController.h"
#import "GameStateModel.h"

static DungeonViewController *shared_instance = nil;
static volatile BOOL solving_in_progress = NO;

@implementation DungeonViewController
@synthesize map_view;
@synthesize map_model;
@synthesize playing_level;

+ (DungeonViewController*)sharedInstance {
	if (!shared_instance) {
		shared_instance = [[DungeonViewController alloc] init];
	}
	return shared_instance;
}

- (id)init {
	if (self = [super init]) {
		mino_steps_remaining = 0;
		playing_level = NO;
		
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].applicationFrame.size.height)];
		contentView.backgroundColor = [UIColor whiteColor];
		self.view = contentView;
		[contentView release];
		
		/* Nav view */
		nav_view = [[NavigationControlView alloc] initWithFrame:CGRectMake(0, ([Globals isScreen35] ? 0 : 64) + kNavConViewYCoord + kNavConViewHeight, self.view.frame.size.width, kNavConViewHeight)];
		nav_view.gestureDelegate = self;
		[contentView addSubview:nav_view];
		[nav_view changeToHandedness:[GameStateModel getRightHanded] animated:NO];
		
		/* Status bar view */
		status_view = [[StatusBarView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, 20)];
		[contentView addSubview:status_view];
		
		/* Map View */
		map_view = [[MapView alloc] initWithFrame:CGRectMake(0, [Globals isScreen35] ? 20 : 44, 320, 320)];
		map_view.gestureDelegate = self;
		[contentView addSubview:map_view];
		
		/* Tutorial View */
		tutorial_view = [[TutorialView alloc] initWithFrame:CGRectMake(0, [Globals isScreen35] ? 180 : 204, 320, 160)];
		tutorial_view.hidden = YES;
		[contentView addSubview:tutorial_view];
		[tutorial_view release];
		
		/* Completion Status */
		comp_view = [[CompletionSummary alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		comp_view.hidden = YES;
		comp_view.navDelegate = self;
		[contentView addSubview:comp_view];
		[comp_view release];
		
		/* Options */
		opt_view = [[OptionsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		opt_view.hidden = YES;
		opt_view.optDelegate = self;
		[contentView addSubview:opt_view];
		[opt_view release];
		
		
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[nav_view release];
	[contentView release];
	[status_view release];
	[map_view release];
    [super dealloc];
}

- (void)_solveThread:(id)obj {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:0];	
	[map_model createSolveMap];
	solving_in_progress = NO;
	if ([GameStateModel getHintsActive]) {
		[nav_view setHintAvailable:YES];
	}
    [pool release];	
}

- (void)_handleBeginSolveThread:(NSTimer*)timer {
	solving_in_progress = YES;
	[NSThread detachNewThreadSelector:@selector(_solveThread:) toTarget:self withObject:nil];
}

- (void)_updateDpadOptions {
	int opts = 0;
	if (![map_model isTheseusDead]) {
		if ([map_model canTheseusMove:DIR_N]) opts |= DIR_N;
		if ([map_model canTheseusMove:DIR_S]) opts |= DIR_S;
		if ([map_model canTheseusMove:DIR_W]) opts |= DIR_W;
		if ([map_model canTheseusMove:DIR_E]) opts |= DIR_E;
	}
	[nav_view.dpad_button setHighlight:opts];
	[nav_view updateButtons:map_model];
}

- (void)flourishIn:(int)level {
	if (flourished_in) return;
	flourished_in = YES;
	playing_level = YES;
	
	map_model = [MapGenerator getMap:level];
	[map_view flourishIn:map_model];
	[self _updateDpadOptions];
	[status_view updateForModel:map_model];
	[status_view appear:YES];
	[nav_view setHintAvailable:NO];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kStatusBarAppearDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	CGPoint p = nav_view.center;
	p.y -= kNavConViewHeight;
	nav_view.center = p;
	[UIView commitAnimations];
	
	[tutorial_view appear:(level < 4)];
	[tutorial_view updateTextForLevel:level];
	
	START_TIMER(1.75, _handleBeginSolveThread:, NO);
}

- (void)flourishTo:(int)level {
	if (!flourished_in) return;
	[map_model cleanSolveMap];
	
	MapModel *old_map = map_model;
	
	map_model = [MapGenerator getMap:level];
	[map_view flourishToMap:map_model];
	[self _updateDpadOptions];
	[status_view updateForModel:map_model];
	[nav_view setHintAvailable:NO];
	
	[old_map resetMap];
	
	[tutorial_view appear:(level < 4)];
	[tutorial_view updateTextForLevel:level];
	
	START_TIMER(1.75, _handleBeginSolveThread:, NO);
}

- (void)handleFlourishOutTimer:(NSTimer*)timer {
	[[FlourishController sharedInstance] transitionToMenu];
}

- (void)flourishOut {
	if (!flourished_in) return;
	flourished_in = NO;
	playing_level = NO;
	[GameStateModel SaveGameState];
	[map_model cleanSolveMap];
	
	float dtime = [map_view flourishOut];
	[status_view appear:NO];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kStatusBarAppearDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	CGPoint p = nav_view.center;
	p.y += kNavConViewHeight;
	nav_view.center = p;
	[UIView commitAnimations];
	
	[map_model resetMap];
	
	START_TIMER(dtime + 0.1, handleFlourishOutTimer:, NO);
	[SoundManager playSound:SND_FLOUT];
	
	[tutorial_view appear:NO];
}

- (void)handleCaught {
	[SoundManager playSound:SND_CAUGHT];
}

- (void)handleSnapshot {
	BOOL endofrope = [map_model snapshotForHistory];
	[status_view updateForModel:map_model];
	if (endofrope) {
		
	}
	[nav_view updateButtons:map_model];
}

- (void)_handleCompSummaryTimer:(NSTimer*)timer {
	[comp_view updateForModel:map_model];
	[comp_view appear:YES];
}

- (void)_handleWinTimer:(NSTimer*)timer {
	/* Suck down Theseus */
	[map_view suckDownTheseus];
	
	START_TIMER(1.5, _handleCompSummaryTimer:, NO);
}

- (void)handleWin {
	[GameStateModel setLevelCompleted:map_model.maze_level];
	[GameStateModel setBestNumMoves:map_model.maze_level moves:map_model.history_cursor];
	
	/* Handle badge */
	if (map_model.history_cursor <= map_model.best_move_pos) {
		[GameStateModel setBadge:3 forLevel:map_model.maze_level];
	} else {
		[GameStateModel setBadge:2 forLevel:map_model.maze_level];
	}
	
	[[MainMenuViewController sharedInstance] updateCellForLevel:map_model.maze_level];

	/* Theseus sucks down and vault appears */
	START_TIMER(kDudeSlideDuration, _handleWinTimer:, NO);
}

- (void)_handleMinotaurSlideTimer:(NSTimer*)timer {
	if ([map_model minotaurWillMove] == DIR_WAIT) {
		[timer invalidate];
		mino_steps_remaining = 0;
		if ([map_model hasTheseusExit]) {
			[self handleWin];
		}
		return;
	}
	
	[map_model moveMinotaur];
	[map_view updateDudePosition:NO];
	[self _updateDpadOptions];
		
	if ([map_model isTheseusDead])
		[self handleCaught];
	else
		[SoundManager playSound:SND_STOMP];
		
	mino_steps_remaining--;
	
	if (mino_steps_remaining == 0 || [map_model minotaurWillMove] == DIR_WAIT) {
		[timer invalidate];		
		mino_steps_remaining = 0;
		[self handleSnapshot];
		if (![map_model isTheseusDead] && [map_model hasTheseusExit]) {
			[self handleWin];
		}
	}
	
}

- (void)acceptNavigation:(DungeonNavigationOptions_t)option {
	switch (option) {
		case DNAV_WAIT:
		case DNAV_MOVE_E:
		case DNAV_MOVE_W:
		case DNAV_MOVE_N:
		case DNAV_MOVE_S: {

			if (mino_steps_remaining > 0) {
				break;
			}
			
			if ([map_model isTheseusDead] || [map_model hasTheseusExit]) {				
				break;
			}
			
			if (![map_model canTheseusMove:option]) {
				break;
			}

			if (option == DNAV_WAIT && ![map_model minotaurWillMove]) {
				[SoundManager playSound:SND_CANNOTNAV];
				break;
			}

			[map_model moveTheseus:option];
			[map_view updateDudePosition:YES];
			[self _updateDpadOptions];
			[SoundManager playSound:SND_SNAP];
			
			/* TODO: tutorial shit? */
			
			if ([map_model minotaurWillMove] != DIR_WAIT) {
				mino_steps_remaining = 2;
				NSTimer *tmpTimer = [NSTimer scheduledTimerWithTimeInterval:kDudeSlideDuration target:self selector:@selector(_handleMinotaurSlideTimer:) userInfo:nil repeats:YES];
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
				[map_view updateDudePosition:NO];
			}
			
		} break;
			
		case DNAV_UNDO: {
			if (mino_steps_remaining > 0 || map_view.still_animating_undo) {
				break;
			}
			
			if (![map_model canUndo]) { [SoundManager playSound:SND_CANNOTNAV]; break; }
			[map_model undo];
			[map_view handleUndo];
			[status_view updateForModel:map_model];
			[self _updateDpadOptions];
			//PlayBwah();
		} break;
			
		case DNAV_RESET_LEVEL: {
			[map_model resetMap];
			[status_view updateForModel:map_model];
			[self _updateDpadOptions];
			[map_view handleReset];
		} break;
			
		case DNAV_EXIT_TO_MAIN: {
			[map_model cancelSolve];
			while (solving_in_progress) { [NSThread sleepForTimeInterval:0.05]; }
			[self flourishOut];
		} break;
			
		case DNAV_NEXT_LEVEL: {
			//[self flourishTo:[GameStateModel getNextIncompleteLevelAfter:map_model.maze_level]];
			[self flourishTo:(map_model.maze_level + 1)%NUM_LEVELS];
		} break;
			
		case DNAV_OPTIONS: {
			[opt_view appear:YES];
		} break;
			
		case DNAV_HINT: {
			if (mino_steps_remaining > 0) {
				break;
			}
			
			int hint_result = [map_model getCurrentPosSolve];
			if (hint_result < 0) {
				[self acceptNavigation:DNAV_UNDO];
				[nav_view createPingForNav:DNAV_UNDO];
				break;
			} else {
				[self acceptNavigation:(hint_result >> 8)];
				[nav_view createPingForNav:(hint_result >> 8)];
				break;
			}
		} break;
			
		default: break;
	}
}

- (void)acceptOptionsChange:(Options_t)option newValue:(BOOL)value {
	switch (option) {
		case OPT_SOUND: {
			[SoundManager setGlobalSound:value];
		} break;
			
		case OPT_HINT: {
			[GameStateModel setHintsActive:!value];
			[nav_view setHintAvailable:!value];
		} break;
			
		case OPT_IDLE: {
			[GameStateModel setIdleTimer:value];
			[UIApplication sharedApplication].idleTimerDisabled = !value;
		} break;
			
		case OPT_RHAND: {
			[GameStateModel setRightHanded:value];
			[nav_view changeToHandedness:value animated:YES];
		}
	}
}

@end
