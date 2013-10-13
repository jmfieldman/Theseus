//
//  GameMenuView.m
//  Theseus
//
//  Created by Jason Fieldman on 9/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameMenuView.h"
#import "GraphicsModel.h"
#import "DataStructures.h"
#import "GlobalSettings.h"

@implementation GameMenuView
@synthesize navDelegate;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		is_showing = NO;
		
		/* Move the menu down below the screen */
		CGPoint p = self.center;
		p.y += frame.size.height;
		self.center = p;
		
		UIFont *butfont = [UIFont systemFontOfSize:14];
		
		/* Initialize the buttons */
		button_reset = [UIButton buttonWithType:UIButtonTypeCustom];
		button_reset.frame = CGRectMake(167,36,140,40);
		button_reset.backgroundColor = [UIColor clearColor];
		button_reset.font = butfont;
		[button_reset setBackgroundImage:[img_button_wait stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateNormal];
		[button_reset setBackgroundImage:[img_button_wait_dn stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateHighlighted];
		[button_reset setTitle:@"Reset Level" forState:UIControlStateNormal];
		[button_reset setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[button_reset addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button_reset];
		
		button_exit = [UIButton buttonWithType:UIButtonTypeCustom];
		button_exit.frame = CGRectMake(13,36,140,40);
		button_exit.backgroundColor = [UIColor clearColor];
		button_exit.font = butfont;
		[button_exit setBackgroundImage:[img_button_wait stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateNormal];
		[button_exit setBackgroundImage:[img_button_wait_dn stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateHighlighted];
		[button_exit setTitle:@"Exit to Main Menu" forState:UIControlStateNormal];
		[button_exit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[button_exit addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button_exit];
		
	
		button_sound_info = [UIButton buttonWithType:UIButtonTypeInfoLight];
		button_sound_info.frame = CGRectMake(270, 85, 30, 30);
		[button_sound_info addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button_sound_info];
		
		button_speed_info = [UIButton buttonWithType:UIButtonTypeInfoLight];
		button_speed_info.frame = CGRectMake(270, 122, 30, 30);
		[button_speed_info addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button_speed_info];
		
		/* Initialize switches */
		switch_sound = [[UISwitch alloc] initWithFrame:CGRectMake(167,85,80,60)];
		[switch_sound setOn:GlobalSoundOn()];
		[switch_sound addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:switch_sound];
		
		switch_speed = [[UISwitch alloc] initWithFrame:CGRectMake(167,122,80,60)];
		[switch_speed setOn:GlobalFastMinotaur()];
		[switch_speed addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:switch_speed];
		
		/* Initialize labels */
		label_sound = [[UILabel alloc] initWithFrame:CGRectMake(13, 85, 140, 30)];
		label_sound.backgroundColor = [UIColor clearColor];
		label_sound.text = @"Enable Sound:";
		label_sound.textColor = [UIColor whiteColor];
		label_sound.font = butfont;
		label_sound.textAlignment = UITextAlignmentRight;
		[self addSubview:label_sound];
		
		label_speed = [[UILabel alloc] initWithFrame:CGRectMake(13, 122, 140, 30)];
		label_speed.backgroundColor = [UIColor clearColor];
		label_speed.text = @"Fast Minotaur:";
		label_speed.textColor = [UIColor whiteColor];
		label_speed.font = butfont;
		label_speed.textAlignment = UITextAlignmentRight;
		[self addSubview:label_speed];
		
	}
	return self;
}

- (void)buttonAction:(id)sender {
	if (sender == button_reset) {
		[navDelegate acceptNavigation:DNAV_RESET_LEVEL];
	} else if (sender == button_exit) {
		[navDelegate acceptNavigation:DNAV_EXIT_TO_MAIN];
	} else if (sender == button_sound_info) {
		info_alert = [[UIAlertView alloc] initWithTitle:@"Enable Sound" message:@"This switch toggles the sound effects on and off."
													delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[info_alert show];
		return;
	} else if (sender == button_speed_info) {
		info_alert = [[UIAlertView alloc] initWithTitle:@"Fast Minotaur" message:@"This setting controls the speed that the Minotaur walks around the dungeon."
											   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[info_alert show];
		return;
	} else if (sender == switch_sound) {
		SetGlobalSoundOn(switch_sound.on);
	} else if (sender == switch_speed) {
		SetGlobalFastMinotaur(switch_speed.on);
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[alertView release];
}

- (void)drawRect:(CGRect)rect {
	[img_game_menu_bk drawInRect:rect];
}

- (void)showMenu:(BOOL)show {
	if (show && is_showing)
		return;
	if (!show && !is_showing)
		return;
	
	is_showing = show;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	if (is_showing) {
		[switch_sound setOn:GlobalSoundOn()];
		[switch_speed setOn:GlobalFastMinotaur()];
		
		CGPoint p = self.center;
		p.y -= self.frame.size.height;
		self.center = p;
	} else {
		CGPoint p = self.center;
		p.y += self.frame.size.height;
		self.center = p;
	}
	[UIView commitAnimations];
}

- (void)dealloc {
	[super dealloc];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];
	
	if (num_touches == 1) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
	
		if (p.x < 35 && p.y < 30)
			[self showMenu:NO];
	}
}


@end
