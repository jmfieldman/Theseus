//
//  NavigationControlView.m
//  Theseus
//
//  Created by Jason Fieldman on 12/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NavigationControlView.h"
#import "SoundManager.h"
#import "DataStructures.h"

@implementation NavigationControlView
@synthesize gestureDelegate;
@synthesize dpad_button;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		dpad_button = [[DpadButton alloc] initWithFrame:CGRectMake(kDpadXCoord, 0, DpadSize, DpadSize)];
		dpad_button.gestureDelegate = self;
		[self addSubview:dpad_button];
		[dpad_button release];
		
		img_wait = [[UIImage imageNamed:@"button_wait.png"] retain];
		img_wait_g = [[UIImage imageNamed:@"button_wait_gray.png"] retain];
		img_undo = [[UIImage imageNamed:@"button_undo.png"] retain];
		img_undo_g = [[UIImage imageNamed:@"button_undo_gray.png"] retain];
		img_hint = [[UIImage imageNamed:@"button_hint.png"] retain];
		img_hint_g = [[UIImage imageNamed:@"button_hint_gray.png"] retain];
		
		button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
		[button_menu setImage:[UIImage imageNamed:@"button_menu.png"] forState:UIControlStateNormal];
		button_menu.adjustsImageWhenHighlighted = NO;
		[button_menu addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchDown];
		button_menu.frame = kNavButtonPosLowerLeft;
		[self addSubview:button_menu];
		
		button_reset = [UIButton buttonWithType:UIButtonTypeCustom];
		[button_reset setImage:[UIImage imageNamed:@"button_reset.png"] forState:UIControlStateNormal];
		button_reset.adjustsImageWhenHighlighted = NO;
		[button_reset addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchDown];
		button_reset.frame = kNavButtonPosUpperLeft;
		[self addSubview:button_reset];
		
		button_wait = [UIButton buttonWithType:UIButtonTypeCustom];
		[button_wait setImage:img_wait forState:UIControlStateNormal];
		button_wait.adjustsImageWhenHighlighted = NO;
		[button_wait addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchDown];
		button_wait.frame = kNavButtonPosUpperRight;
		[self addSubview:button_wait];
		
		button_undo = [UIButton buttonWithType:UIButtonTypeCustom];
		[button_undo setImage:img_undo forState:UIControlStateNormal];
		button_undo.adjustsImageWhenHighlighted = NO;
		[button_undo addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchDown];
		button_undo.frame = kNavButtonPosLowerRight;
		[self addSubview:button_undo];
		
		button_hint = [UIButton buttonWithType:UIButtonTypeCustom];
		[button_hint setImage:img_hint forState:UIControlStateNormal];
		button_hint.adjustsImageWhenHighlighted = NO;
		[button_hint addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchDown];
		button_hint.frame = kNavButtonPosNTUpperLeft;
		[self addSubview:button_hint];
		
		button_options = [UIButton buttonWithType:UIButtonTypeCustom];
		[button_options setImage:[UIImage imageNamed:@"button_options.png"] forState:UIControlStateNormal];
		button_options.adjustsImageWhenHighlighted = NO;
		[button_options addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchDown];
		button_options.frame = kNavButtonPosNTLowerLeft;
		[self addSubview:button_options];
		
		label_menu = [[UILabel alloc] initWithFrame:kNavLabelPosLowerLeft];
		label_menu.text = JFLocalizedString(@"MenuLabel", @"MENU");
		label_menu.font = [UIFont fontWithName:kNavLabelFontFamily size:kNavLabelFontSize];
		label_menu.textAlignment = UITextAlignmentCenter;
		[self addSubview:label_menu];
		[label_menu release];
		
		label_reset = [[UILabel alloc] initWithFrame:kNavLabelPosUpperLeft];
		label_reset.text = JFLocalizedString(@"ResetLabel", @"RESET");
		label_reset.font = [UIFont fontWithName:kNavLabelFontFamily size:kNavLabelFontSize];
		label_reset.textAlignment = UITextAlignmentCenter;
		[self addSubview:label_reset];
		[label_reset release];		
		
		label_undo = [[UILabel alloc] initWithFrame:kNavLabelPosLowerRight];
		label_undo.text = JFLocalizedString(@"UndoLabel", @"UNDO");
		label_undo.font = [UIFont fontWithName:kNavLabelFontFamily size:kNavLabelFontSize];
		label_undo.textAlignment = UITextAlignmentCenter;
		[self addSubview:label_undo];
		[label_undo release];
		
		label_wait = [[UILabel alloc] initWithFrame:kNavLabelPosUpperRight];
		label_wait.text = JFLocalizedString(@"WaitLabel", @"WAIT");
		label_wait.font = [UIFont fontWithName:kNavLabelFontFamily size:kNavLabelFontSize];
		label_wait.textAlignment = UITextAlignmentCenter;
		[self addSubview:label_wait];
		[label_wait release];
		
		label_hint = [[UILabel alloc] initWithFrame:kNavLabelPosNTUpperLeft];
		label_hint.text = JFLocalizedString(@"HintLabel", @"HINT");
		label_hint.font = [UIFont fontWithName:kNavLabelFontFamily size:kNavLabelFontSize];
		label_hint.textAlignment = UITextAlignmentCenter;
		[self addSubview:label_hint];
		[label_hint release];
		
		label_options = [[UILabel alloc] initWithFrame:kNavLabelPosNTLowerLeft];
		label_options.text = JFLocalizedString(@"OptionsLabel", @"OPTIONS");
		label_options.font = [UIFont fontWithName:kNavLabelFontFamily size:kNavLabelFontSize];
		label_options.textAlignment = UITextAlignmentCenter;
		[self addSubview:label_options];
		[label_options release];
		
		/* Hint halo */
		hint_halo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hint_halo.png"]];
		hint_halo.frame = CGRectMake(20, 20, 60, 60);
		hint_halo.userInteractionEnabled = NO;
		hint_halo.alpha = 0;
		[self addSubview:hint_halo];
		[hint_halo release];
    }
    return self;
}

- (void)dealloc {
	[gestureDelegate release];
    [super dealloc];
}

#define HINTHALO_W 80
#define HINTHALO_H 80
#define HINTHALO_W2 (HINTHALO_W/2)
#define HINTHALO_H2 (HINTHALO_H/2)
#define HINTHALO_W4 (HINTHALO_W/4)
#define HINTHALO_H4 (HINTHALO_H/4)

/* Obsolete */
- (void)_handleHintPingExitAt:(NSTimer*)t {
	CGRect frect = CGRectMake(hint_halo.center.x - HINTHALO_W2, hint_halo.center.y - HINTHALO_H2, HINTHALO_W, HINTHALO_H);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	hint_halo.alpha = 0;
	hint_halo.frame = frect;
	[UIView commitAnimations];
}

- (void)_handleHintPingAt:(CGPoint)p {
	CGRect prect = CGRectMake(p.x, p.y, 0, 0);
	//CGRect mrect = CGRectMake(p.x - HINTHALO_W4, p.y - HINTHALO_H4, HINTHALO_W2, HINTHALO_H2);
	CGRect frect = CGRectMake(p.x - HINTHALO_W2, p.y - HINTHALO_H2, HINTHALO_W, HINTHALO_H);
	
	hint_halo.frame = prect;
	hint_halo.hidden = NO;
	hint_halo.alpha = 1;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.7];
	hint_halo.alpha = 0.0;
	hint_halo.frame = frect;
	[UIView commitAnimations];

	//START_TIMER(0.3, _handleHintPingExitAt:, NO);	
}

- (void)createPingForNav:(DungeonNavigationOptions_t)nav_opt {
	CGPoint p = CGPointZero;
	switch (nav_opt) {
		case DNAV_MOVE_N: p = CGPointMake(dpad_button.frame.origin.x + (DpadSize/2), dpad_button.frame.origin.y + (DpadSize/4) - 3); break;
		case DNAV_MOVE_S: p = CGPointMake(dpad_button.frame.origin.x + (DpadSize/2), dpad_button.frame.origin.y + (3*DpadSize/4) + 3); break;
		case DNAV_MOVE_W: p = CGPointMake(dpad_button.frame.origin.x + (DpadSize/4) - 3, dpad_button.frame.origin.y + (DpadSize/2)); break;
		case DNAV_MOVE_E: p = CGPointMake(dpad_button.frame.origin.x + (3*DpadSize/4) + 3, dpad_button.frame.origin.y + (DpadSize/2)); break;
		case DNAV_WAIT: p = CGPointMake(button_wait.center.x, button_wait.center.y-7); break;
		case DNAV_UNDO: p = CGPointMake(button_undo.center.x, button_undo.center.y-7); break;	
	}
		
	[self _handleHintPingAt:p];
}

- (void)handleButton:(id)sender {
	if (sender == button_menu)  [gestureDelegate acceptNavigation:DNAV_EXIT_TO_MAIN];
	if (sender == button_undo)  [gestureDelegate acceptNavigation:DNAV_UNDO];
	if (sender == button_wait)  [gestureDelegate acceptNavigation:DNAV_WAIT];
	if (sender == button_reset) [gestureDelegate acceptNavigation:DNAV_RESET_LEVEL];
	if (sender == button_options) [gestureDelegate acceptNavigation:DNAV_OPTIONS];
	if (sender == button_hint) {
		if (hints_available) {
			[gestureDelegate acceptNavigation:DNAV_HINT];
		} else {
			[SoundManager playSound:SND_CANNOTNAV];
		}
	}	
}

- (void)acceptNavigation:(DungeonNavigationOptions_t)option {
	[gestureDelegate acceptNavigation:option];
}

- (void)updateButtons:(MapModel*)model {
	if ([model minotaurWillMove]) {
		[button_wait setImage:img_wait forState:UIControlStateNormal];
		[button_wait setImage:img_wait forState:UIControlStateHighlighted];
	} else {
		[button_wait setImage:img_wait_g forState:UIControlStateNormal];
		[button_wait setImage:img_wait_g forState:UIControlStateHighlighted];
	}
	
	if (model.history_cursor == 0) {
		[button_undo setImage:img_undo_g forState:UIControlStateNormal];
		[button_undo setImage:img_undo_g forState:UIControlStateHighlighted];
	} else {
		[button_undo setImage:img_undo forState:UIControlStateNormal];
		[button_undo setImage:img_undo forState:UIControlStateHighlighted];
	}
}

- (void)changeToHandedness:(BOOL)right animated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView	setAnimationDuration:kHandednessChangeDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	}
	
	if (right) {
		button_menu.frame = kNavButtonPosLowerLeft;
		button_reset.frame = kNavButtonPosUpperLeft;
		button_wait.frame = kNavButtonPosUpperRight;
		button_undo.frame = kNavButtonPosLowerRight;
		button_hint.frame = kNavButtonPosNTUpperLeft;
		button_options.frame = kNavButtonPosNTLowerLeft;
	
		label_menu.frame = kNavLabelPosLowerLeft;
		label_reset.frame = kNavLabelPosUpperLeft;
		label_undo.frame = kNavLabelPosLowerRight;
		label_wait.frame = kNavLabelPosUpperRight;
		label_hint.frame = kNavLabelPosNTUpperLeft;
		label_options.frame = kNavLabelPosNTLowerLeft;
		
		dpad_button.frame = CGRectMake(kDpadXCoord, 0, DpadSize, DpadSize);
	} else {
		button_menu.frame = kNavButtonPosLowerRight;
		button_reset.frame = kNavButtonPosUpperRight;
		button_wait.frame = kNavButtonPosUpperLeft;
		button_undo.frame = kNavButtonPosLowerLeft;
		button_hint.frame = kNavButtonPosNTUpperRight;
		button_options.frame = kNavButtonPosNTLowerRight;
		
		label_menu.frame = kNavLabelPosLowerRight;
		label_reset.frame = kNavLabelPosUpperRight;
		label_undo.frame = kNavLabelPosLowerLeft;
		label_wait.frame = kNavLabelPosUpperLeft;
		label_hint.frame = kNavLabelPosNTUpperRight;
		label_options.frame = kNavLabelPosNTLowerRight;

		dpad_button.frame = CGRectMake(kDpadXCoordL, 0, DpadSize, DpadSize);
	}
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)setHintAvailable:(BOOL)avail {
	hints_available = avail;
	if (avail) {
		[button_hint setImage:img_hint forState:UIControlStateNormal];
	} else {
		[button_hint setImage:img_hint_g forState:UIControlStateNormal];
	}
}

@end
