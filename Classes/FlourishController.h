//
//  FlourishController.h
//  Theseus
//
//  Created by Jason Fieldman on 12/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DungeonViewController.h"
#import "MainMenuViewController.h"

typedef enum {
	CONT_MENU,
	CONT_DUNGEON,
} CurrentWindow_t;

@interface FlourishController : UIViewController {
	UIView *contentView;
	
	DungeonViewController *dvc;
	MainMenuViewController *mmvc;
	
	CurrentWindow_t current_window;
}

+ (FlourishController*) sharedInstance;

- (void)transitionToDungeon:(int)level;
- (void)transitionToMenu;

@end
