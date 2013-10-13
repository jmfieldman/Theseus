//
//  TableScrollbarView.m
//  Theseus
//
//  Created by Jason Fieldman on 9/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableScrollbarView.h"


@implementation TableScrollbarView
@synthesize scrollDelegate;

#define WHICH_NONE 0
#define WHICH_SLIDER 1
#define WHICH_TOP 2
#define WHICH_BOT 3

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		my_width = frame.size.width;
		my_height = frame.size.height;
		my_radius = my_width / 2;
		my_pos = 0;
		
		which_selecting = WHICH_NONE;
		which_down = WHICH_NONE;
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	/* Top of the bar */
	if (which_down == WHICH_TOP) {
		CGContextSetRGBFillColor(c, BAR_SEL);
	} else {
		CGContextSetRGBFillColor(c, BAR_UNSEL);
	}
	CGContextFillEllipseInRect(c, CGRectMake(0, 0, my_width, my_width));
	CGContextFillRect(c, CGRectMake(0, my_radius, my_width, my_pos));
	
	/* Bottom of the bar */
	if (which_down == WHICH_BOT) {
		CGContextSetRGBFillColor(c, BAR_SEL);
	} else {
		CGContextSetRGBFillColor(c, BAR_UNSEL);
	}
	CGContextFillEllipseInRect(c, CGRectMake(0, my_height - my_width, my_width, my_width));
	CGContextFillRect(c, CGRectMake(0, my_radius + my_pos, my_width, my_height - my_width - my_pos));
	
	/* Slider */
	if (which_down == WHICH_SLIDER) {
		CGContextSetRGBFillColor(c, SLIDER_SEL);
	} else {
		CGContextSetRGBFillColor(c, SLIDER_UNSEL);
	}
	CGContextFillEllipseInRect(c, CGRectMake(0, my_pos, my_width, my_width));
	CGContextFillEllipseInRect(c, CGRectMake(0, my_pos + SLIDER_HEIGHT - my_width, my_width, my_width));
	CGContextFillRect(c, CGRectMake(0, my_pos + my_radius, my_width, SLIDER_HEIGHT - my_width));
	
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1);
	CGContextBeginPath(c);
	CGContextMoveToPoint(c, 4, my_pos + (SLIDER_HEIGHT/2) - 2);
	CGContextAddLineToPoint(c, my_width - 4, my_pos + (SLIDER_HEIGHT/2) - 2);
	CGContextMoveToPoint(c, 4, my_pos + (SLIDER_HEIGHT/2) + 2);
	CGContextAddLineToPoint(c, my_width - 4, my_pos + (SLIDER_HEIGHT/2) + 2);
	CGContextStrokePath(c);
	
}

- (void)updateWithScroll:(UIScrollView *)view {
	//if (!view.dragging) return;
	
	int total_y = (int)view.contentSize.height;
	int frame_y = view.frame.size.height;
	int offset_y = (int)view.contentOffset.y;
	
	total_y -= frame_y;
	my_pos = (offset_y * (my_height - SLIDER_HEIGHT)/ total_y);
	
	[self setNeedsDisplay];
}

- (void)dealloc {
	[super dealloc];
}

/* ------------------ TOUCHES ------------------- */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];
	
	if (num_touches == 1) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		
		if (p.y < my_pos) {
			[scrollDelegate acceptTableScroll:YES pageUp:YES position:0];
		} else if (p.y > (my_pos + SLIDER_HEIGHT)) {
			[scrollDelegate acceptTableScroll:YES pageUp:NO position:0];
		} else {
			which_selecting = WHICH_SLIDER;
			which_down = WHICH_SLIDER;
			start_drag_y = p.y;
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];

	if (which_selecting != WHICH_SLIDER)
		return;
	
	/* Handle dragging */
	if (num_touches == 1) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		
		//my_pos = (p.y - start_drag_y);
		my_pos += (p.y - start_drag_y);
		start_drag_y = p.y;
		
		if (my_pos < 0) my_pos = 0;
		if (start_drag_y < 0) start_drag_y = 0;
		if (my_pos > (my_height - SLIDER_HEIGHT)) my_pos = my_height - SLIDER_HEIGHT;
		if (start_drag_y >= my_height) start_drag_y = my_height;
		
		[self setNeedsDisplay];
		[scrollDelegate acceptTableScroll:NO pageUp:NO position:((double)my_pos / (my_height - SLIDER_HEIGHT))];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	which_selecting = WHICH_NONE;
	which_down = WHICH_NONE;	
	[self setNeedsDisplay];
}



@end
