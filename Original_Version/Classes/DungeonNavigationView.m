//
//  DungeonNavigationView.m
//  Theseus
//
//  Created by Jason Fieldman on 9/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DungeonNavigationView.h"

/* dpad helpers */
CGRect dpad_rect;

/* Gets the DPAD direction based on the X/Y coords - uses dpad_rect */
int GetDPADDir(int x, int y) {
	if (x < dpad_rect.origin.x ||
		x > (dpad_rect.origin.x + dpad_rect.size.width) ||
		y < dpad_rect.origin.y ||
		y > (dpad_rect.origin.y + dpad_rect.size.height)) {
		return 0;
	}
	
	int rx = x - dpad_rect.origin.x;
	int ry = y - dpad_rect.origin.y;
	
	if (rx > ry) {
		if ( (rx + ry) > dpad_rect.size.width )
			return DIR_E;
		return DIR_N;
	} else {
		if ( (rx + ry) > dpad_rect.size.width )
			return DIR_S;
		return DIR_W;
	}
}


@implementation DungeonNavigationView

@synthesize navDelegate;




- (id)initWithFrame:(CGRect)frame withMap:(MapModel*)map {
	if (self = [super initWithFrame:frame]) {
		map_model = map;
		dpad_pressed = 0;
		
		dpad_rect = CGRectMake(110, 10, 120, 120);
		
		button_wait = [UIButton buttonWithType:UIButtonTypeCustom];
		button_wait.frame = CGRectMake(245,15,65,50);
		button_wait.backgroundColor = [UIColor clearColor];
		[button_wait setBackgroundImage:img_button_wait forState:UIControlStateNormal];
		[button_wait setBackgroundImage:img_button_wait_dn forState:UIControlStateHighlighted];
		[button_wait setTitle:@"Wait" forState:UIControlStateNormal];
		[button_wait setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[button_wait addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button_wait];
		
		button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
		button_menu.frame = CGRectMake(245,75,65,50);
		button_menu.backgroundColor = [UIColor clearColor];
		[button_menu setBackgroundImage:img_button_wait forState:UIControlStateNormal];
		[button_menu setBackgroundImage:img_button_wait_dn forState:UIControlStateHighlighted];
		[button_menu setTitle:@"Menu" forState:UIControlStateNormal];
		[button_menu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];	
		[button_menu addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button_menu];
		
		button_undo = [UIButton buttonWithType:UIButtonTypeCustom];
		button_undo.frame = CGRectMake(10,45,35,50);
		button_undo.backgroundColor = [UIColor clearColor];
		[button_undo setBackgroundImage:img_undo_enabled forState:UIControlStateNormal];
		[button_undo setBackgroundImage:img_undo_enabled_dn forState:UIControlStateHighlighted];
		[button_undo setBackgroundImage:img_undo_disabled forState:UIControlStateDisabled];
		[button_undo addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button_undo];
		
		button_redo = [UIButton buttonWithType:UIButtonTypeCustom];
		button_redo.frame = CGRectMake(55,45,35,50);
		button_redo.backgroundColor = [UIColor clearColor];
		[button_redo setBackgroundImage:img_redo_enabled forState:UIControlStateNormal];
		[button_redo setBackgroundImage:img_redo_enabled_dn forState:UIControlStateHighlighted];
		[button_redo setBackgroundImage:img_redo_disabled forState:UIControlStateDisabled];
		[button_redo addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button_redo];
		
		UIFont *smallfont = [UIFont systemFontOfSize:14];
		
		label_undo = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 45, 19)];
		label_undo.backgroundColor = [UIColor clearColor];
		label_undo.text = @"Undo";
		label_undo.textColor = [UIColor whiteColor];
		label_undo.font = smallfont;
		label_undo.textAlignment = UITextAlignmentCenter;
		[self addSubview:label_undo];
		
		label_redo = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 45, 19)];
		label_redo.backgroundColor = [UIColor clearColor];
		label_redo.text = @"Redo";
		label_redo.textColor = [UIColor whiteColor];
		label_redo.font = smallfont;
		label_redo.textAlignment = UITextAlignmentCenter;
		[self addSubview:label_redo];

		label_move = [[UILabel alloc] initWithFrame:CGRectMake(10, 98, 120, 19)];
		label_move.backgroundColor = [UIColor clearColor];
		label_move.text = @"Move: 0/0";
		label_move.textColor = [UIColor whiteColor];
		label_move.font = smallfont;
		label_move.textAlignment = UITextAlignmentLeft;
		[self addSubview:label_move];
		
		label_best = [[UILabel alloc] initWithFrame:CGRectMake(10, 116, 120, 19)];
		label_best.backgroundColor = [UIColor clearColor];
		label_best.text = @"Gold: 0";
		label_best.textColor = [UIColor whiteColor];
		label_best.font = smallfont;
		label_best.textAlignment = UITextAlignmentLeft;
		[self addSubview:label_best];
		
		[self updateURM];
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	//CGContextRef c = UIGraphicsGetCurrentContext();
	
	/* Draw background */
	//CGContextSetRGBFillColor(c, NAV_BACKBORDER_RGBA);
	//CGContextFillRect(c, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	//CGContextSetRGBFillColor(c, NAV_BACKGROUND_RGBA);
	//CGContextFillRect(c, CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-10));
	
	//[img_nav_bk drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	
	/* Draw dpad [CAN/NOT][UN/SEL][DIR] */
	[img_dpad[ [map_model canTheseusMove:DIR_N] ? 1 : 0 ][ (dpad_pressed == DIR_N) ? 1 : 0 ][DIR_N] drawInRect:dpad_rect];
	[img_dpad[ [map_model canTheseusMove:DIR_W] ? 1 : 0 ][ (dpad_pressed == DIR_W) ? 1 : 0 ][DIR_W] drawInRect:dpad_rect];
	[img_dpad[ [map_model canTheseusMove:DIR_E] ? 1 : 0 ][ (dpad_pressed == DIR_E) ? 1 : 0 ][DIR_E] drawInRect:dpad_rect];
	[img_dpad[ [map_model canTheseusMove:DIR_S] ? 1 : 0 ][ (dpad_pressed == DIR_S) ? 1 : 0 ][DIR_S] drawInRect:dpad_rect];
}


- (void)buttonAction:(id)sender {
	if (sender == button_menu) {
		PlaySnap();
		[self.navDelegate acceptNavigation:DNAV_GAME_MENU];
	} else if (sender == button_wait) {
		PlaySnap();
		[self.navDelegate acceptNavigation:DNAV_WAIT];
	} else if (sender == button_undo) {
		[self,navDelegate acceptNavigation:DNAV_UNDO];
	} else if (sender == button_redo) {
		[self,navDelegate acceptNavigation:DNAV_REDO];
	}
}

/* Updates the state of the undo/redo/move label/buttons based on the model */
- (void)updateURM {
	button_undo.enabled = [map_model canUndo];
	button_redo.enabled = [map_model canRedo];
	label_move.text = [NSString stringWithFormat:@"Move: %d/%d", map_model.history_cursor, map_model.history_max];
	label_best.text = [NSString stringWithFormat:@"Gold: %d", map_model.best_move_pos];
}

- (void)updateWithMap:(MapModel*)map {
	map_model = map;
	[self updateURM];
}

- (void)dealloc {
	[super dealloc];
}


/* -------------------------------------------------------------------- */
/* --------------------------- TOUCH EVENTS --------------------------- */
/* -------------------------------------------------------------------- */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];
	
	if (num_touches == 1) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		dpad_pressed = GetDPADDir(p.x, p.y);

		if (dpad_pressed) {
			PlaySnap();
			[self setNeedsDisplay];
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];

#define BUTTON_SENSITIVITY 30
	
	/* Handle dragging */
	if (num_touches == 1) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		
		if (p.x < (dpad_rect.origin.x - BUTTON_SENSITIVITY) ||
			p.x > (dpad_rect.origin.x + dpad_rect.size.width + BUTTON_SENSITIVITY) ||
			p.y < (dpad_rect.origin.y - BUTTON_SENSITIVITY) ||
			p.y > (dpad_rect.origin.y + dpad_rect.size.height + BUTTON_SENSITIVITY)) {
			dpad_pressed = 0;
			[self setNeedsDisplay];
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];
	
	/* Was this a tap? */
	if (num_touches == 1 && dpad_pressed) {
		//UITouch *t = [myTouches objectAtIndex:0];
		//CGPoint p  = [t locationInView:self];
		
		switch (dpad_pressed) {
			case DIR_N:
				[self.navDelegate acceptNavigation:DNAV_MOVE_N];
				break;
			case DIR_W:
				[self.navDelegate acceptNavigation:DNAV_MOVE_W];
				break;
			case DIR_E:
				[self.navDelegate acceptNavigation:DNAV_MOVE_E];
				break;
			case DIR_S:
				[self.navDelegate acceptNavigation:DNAV_MOVE_S];
				break;
		}
		
		dpad_pressed = 0;
		[self setNeedsDisplay];
	}
	
}


@end
