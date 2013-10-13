//
//  DpadButton.m
//  Theseus
//
//  Created by Jason Fieldman on 12/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DpadButton.h"
#import "SoundManager.h"

@implementation DpadButton
@synthesize gestureDelegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		dpad = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dpad.png"]];
		dpad.userInteractionEnabled = NO;
		dpad.frame = CGRectMake(0, 0, DpadSize, DpadSize);
		[self addSubview:dpad];
		[dpad release];
		
		dpad_n = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dpad_N.png"]];
		dpad_n.userInteractionEnabled = NO;
		dpad_n.frame = CGRectMake(0, 0, DpadSize, DpadMidSize);
		dpad_n.hidden = YES;
		[self addSubview:dpad_n];
		[dpad_n release];
		
		dpad_s = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dpad_S.png"]];
		dpad_s.userInteractionEnabled = NO;
		dpad_s.frame = CGRectMake(0, DpadMidSize*2, DpadSize, DpadMidSize);
		dpad_s.hidden = YES;
		[self addSubview:dpad_s];
		[dpad_s release];

		dpad_w = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dpad_W.png"]];
		dpad_w.userInteractionEnabled = NO;
		dpad_w.frame = CGRectMake(0, 0, DpadMidSize, DpadSize);
		dpad_w.hidden = YES;
		[self addSubview:dpad_w];
		[dpad_w release];

		dpad_e = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dpad_E.png"]];
		dpad_e.userInteractionEnabled = NO;
		dpad_e.frame = CGRectMake(DpadMidSize*2, 0, DpadMidSize, DpadSize);
		dpad_e.hidden = YES;
		[self addSubview:dpad_e];
		[dpad_e release];
		
    }
    return self;
}


- (void)dealloc {
	[dpad release];
	[dpad_n release];
	[dpad_s release];
	[dpad_w release];
	[dpad_e release];
	[gestureDelegate release];
    [super dealloc];
}

- (void) setHighlight:(int)dirs {
	dpad_n.hidden = (dirs & DIR_N) ? NO : YES;
	dpad_s.hidden = (dirs & DIR_S) ? NO : YES;
	dpad_w.hidden = (dirs & DIR_W) ? NO : YES;
	dpad_e.hidden = (dirs & DIR_E) ? NO : YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];
	
	if (num_touches) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		if (p.x > p.y) {
			if ((p.x + p.y) > DpadSize) {
				if (dpad_e.hidden) [SoundManager playSound:SND_CANNOTNAV];
				else [gestureDelegate acceptNavigation:DNAV_MOVE_E];
			} else {
				if (dpad_n.hidden) [SoundManager playSound:SND_CANNOTNAV];
				else [gestureDelegate acceptNavigation:DNAV_MOVE_N];
			}
		} else {
			if ((p.x + p.y) > DpadSize) {
				if (dpad_s.hidden) [SoundManager playSound:SND_CANNOTNAV];
				else [gestureDelegate acceptNavigation:DNAV_MOVE_S];
			} else {
				if (dpad_w.hidden) [SoundManager playSound:SND_CANNOTNAV];
				else [gestureDelegate acceptNavigation:DNAV_MOVE_W];
			}
		}
	}
}

@end
