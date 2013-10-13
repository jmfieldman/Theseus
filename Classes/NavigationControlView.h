//
//  NavigationControlView.h
//  Theseus
//
//  Created by Jason Fieldman on 12/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStructures.h"
#import "DpadButton.h"
#import "MapModel.h"

#define kHandednessChangeDuration 0.5

#define kDpadXCoord 130.0
#define kDpadXCoordL 70.0

#define kNavButtonSize 60.0
#define kNavButtonInset 0.0

#define kNavLabelHeight 15.0
#define kNavLabelYOffset (kNavButtonSize - kNavLabelHeight)

#define kNavLabelFontFamily @"Trebuchet MS"
#define kNavLabelFontSize   12

/* Label pos */
#define kNavLabelPosLowerRight CGRectMake(self.frame.size.width - kNavButtonInset - kNavButtonSize, kNavButtonSize + kNavLabelYOffset, kNavButtonSize, kNavLabelHeight)
#define kNavLabelPosUpperRight CGRectMake(self.frame.size.width - kNavButtonInset - kNavButtonSize, kNavLabelYOffset, kNavButtonSize, kNavLabelHeight)
#define kNavLabelPosLowerLeft CGRectMake(kNavButtonInset, kNavButtonSize + kNavLabelYOffset, kNavButtonSize, kNavLabelHeight)
#define kNavLabelPosUpperLeft CGRectMake(kNavButtonInset, kNavLabelYOffset, kNavButtonSize, kNavLabelHeight)

#define kNavLabelPosNTLowerRight CGRectMake(self.frame.size.width - kNavButtonInset - kNavButtonSize*2, kNavButtonSize + kNavLabelYOffset, kNavButtonSize, kNavLabelHeight)
#define kNavLabelPosNTUpperRight CGRectMake(self.frame.size.width - kNavButtonInset - kNavButtonSize*2, kNavLabelYOffset, kNavButtonSize, kNavLabelHeight)
#define kNavLabelPosNTLowerLeft CGRectMake(kNavButtonInset + kNavButtonSize, kNavButtonSize + kNavLabelYOffset, kNavButtonSize, kNavLabelHeight)
#define kNavLabelPosNTUpperLeft CGRectMake(kNavButtonInset + kNavButtonSize, kNavLabelYOffset, kNavButtonSize, kNavLabelHeight)


/* Button pos */
#define kNavButtonPosLowerRight CGRectMake(self.frame.size.width - kNavButtonInset - kNavButtonSize, self.frame.size.height - kNavButtonSize, kNavButtonSize, kNavButtonSize)
#define kNavButtonPosUpperRight CGRectMake(self.frame.size.width - kNavButtonInset - kNavButtonSize, 0, kNavButtonSize, kNavButtonSize)
#define kNavButtonPosLowerLeft CGRectMake(kNavButtonInset, self.frame.size.height - kNavButtonSize, kNavButtonSize, kNavButtonSize)
#define kNavButtonPosUpperLeft CGRectMake(kNavButtonInset, 0, kNavButtonSize, kNavButtonSize)

#define kNavButtonPosNTLowerRight CGRectMake(self.frame.size.width - kNavButtonInset - kNavButtonSize*2, self.frame.size.height - kNavButtonSize, kNavButtonSize, kNavButtonSize)
#define kNavButtonPosNTUpperRight CGRectMake(self.frame.size.width - kNavButtonInset - kNavButtonSize*2, 0, kNavButtonSize, kNavButtonSize)
#define kNavButtonPosNTLowerLeft CGRectMake(kNavButtonInset + kNavButtonSize, self.frame.size.height - kNavButtonSize, kNavButtonSize, kNavButtonSize)
#define kNavButtonPosNTUpperLeft CGRectMake(kNavButtonInset + kNavButtonSize, 0, kNavButtonSize, kNavButtonSize)


@interface NavigationControlView : UIView <DungeonNavigationDelegate> {
	DpadButton *dpad_button;
	
	UIButton *button_undo;
	UIButton *button_wait;
	UIButton *button_reset;
	UIButton *button_menu;
	UIButton *button_options;
	UIButton *button_hint;
	
	UILabel  *label_undo;
	UILabel  *label_wait;
	UILabel  *label_reset;
	UILabel  *label_menu;
	UILabel  *label_options;
	UILabel  *label_hint;
	
	/* Image holders for those that can change */
	UIImage *img_wait;
	UIImage *img_undo;
	UIImage *img_wait_g;
	UIImage *img_undo_g;
	UIImage *img_hint;
	UIImage *img_hint_g;
	
	BOOL hints_available;
	
	id<DungeonNavigationDelegate> gestureDelegate;
	
	/* Hint halo */
	UIImageView *hint_halo;
}

@property (retain) id<DungeonNavigationDelegate> gestureDelegate;
@property (readonly) DpadButton *dpad_button;

- (void)acceptNavigation:(DungeonNavigationOptions_t)option;
- (void)updateButtons:(MapModel*)model;
- (void)changeToHandedness:(BOOL)right animated:(BOOL)animated;

- (void)setHintAvailable:(BOOL)avail;
- (void)createPingForNav:(DungeonNavigationOptions_t)nav_opt;

@end
