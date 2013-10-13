//
//  DungeonNavigationView.h
//  Theseus
//
//  Created by Jason Fieldman on 9/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapModel.h"
#import "GraphicsModel.h"
#import "DataStructures.h"
#import "Sound.h"

#define NAV_BACKBORDER_RGBA  10/255.0, 10/255.0, 10/255.0, 1
#define NAV_BACKGROUND_RGBA  30/255.0, 54/255.0, 102/255.0, 1

@interface DungeonNavigationView : UIView {
	/* Underlying map model */
	MapModel *map_model;
	
	/* Pressed dpad direction */
	int dpad_pressed;
	
	/* Navigation Delegate */
	id<DungeonNavigationDelegate> navDelegate;
	
	/* Navigation buttons */
	UIButton *button_wait;
	UIButton *button_menu;
	UIButton *button_undo;
	UIButton *button_redo;
	
	/* Labels for move counter */
	UILabel *label_undo;
	UILabel *label_redo;
	UILabel *label_move;
	UILabel *label_best;
}

- (id)initWithFrame:(CGRect)frame withMap:(MapModel*)map;
- (void)updateWithMap:(MapModel*)map;
- (void)updateURM;

@property (assign) id<DungeonNavigationDelegate> navDelegate;

@end
