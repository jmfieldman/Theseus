//
//  FlourishController.m
//  Theseus
//
//  Created by Jason Fieldman on 12/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FlourishController.h"
#import "GameStateModel.h"

static FlourishController *shared_instance = nil;

@implementation FlourishController

+ (FlourishController*) sharedInstance {
	if (!shared_instance) {
		shared_instance = [[FlourishController alloc] init];
	}
	return shared_instance;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (id) init {
	if (self = [super init]) {
		dvc = [DungeonViewController sharedInstance];
		mmvc = [MainMenuViewController sharedInstance];
		
		current_window = -1;
		//self.view = mmvc.view;
		
		
		/* WHAT THE FUCK WAS I THINKING? */
		self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
		self.view.backgroundColor = [UIColor whiteColor];
		
		[self.view addSubview:dvc.view];
		[self.view addSubview:mmvc.view];
		
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

- (void)transitionToDungeon:(int)level {
	if (current_window == CONT_DUNGEON) return;
	current_window = CONT_DUNGEON;	
	
	//self.view = dvc.view;
	dvc.view.alpha = 1;
	mmvc.view.alpha = 0;
	[dvc flourishIn:level];
}

- (void)transitionToMenu {
	if (current_window == CONT_MENU) return;
	current_window = CONT_MENU;
	
	//self.view = mmvc.view;
	dvc.view.alpha = 0;
	mmvc.view.alpha = 1;
	[mmvc flourishIn];
}

@end
