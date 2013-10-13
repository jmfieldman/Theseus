//
//  GameMenuView.h
//  Theseus
//
//  Created by Jason Fieldman on 9/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStructures.h"
#import "GraphicsModel.h"

@interface GameMenuView : UIView {
	BOOL is_showing;
	
	/* Buttons and labels */
	UIButton *button_reset;
	UIButton *button_exit;
	UIButton *button_sound_info;
	UIButton *button_speed_info;
	
	UILabel *label_speed;
	UILabel *label_sound;
	
	UISwitch *switch_speed;
	UISwitch *switch_sound;
	
	/* Info alerts */
	UIAlertView *info_alert;
	
	/* Navigation Delegate */
	id<DungeonNavigationDelegate> navDelegate;

}

- (void)showMenu:(BOOL)show;

@property (assign) id<DungeonNavigationDelegate> navDelegate;

@end
