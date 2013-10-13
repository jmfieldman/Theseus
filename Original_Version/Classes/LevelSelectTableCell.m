//
//  LevelSelectTableCell.m
//  Theseus
//
//  Created by Jason Fieldman on 9/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LevelSelectTableCell.h"
#import "GraphicsModel.h"
#import "GameStateModel.h"

extern char *display_names[NUM_LEVEL_NAMES];

@implementation LevelSelectTableCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		// Initialization code
	}
	return self;
}

- (id) initWithLevel:(int)i {
	if (self = [super initWithFrame:CGRectMake(0,0,0,0) reuseIdentifier:nil]) {
		level = i;
		map_model = [MapGenerator getMap:level];
		
		int prev_w = map_model.size.w * 8;
		int prev_h = map_model.size.h * 8;
		
		map_view = [[MapView alloc] initWithFrame:CGRectMake(100-prev_w/2,40-prev_h/2,prev_w,prev_h) withMap:map_model withBorder:0];
		[map_view setPreviewMode:YES];
		[self addSubview:map_view];
	}
	return self;
}

- (void) drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	/* Background for Selected? */
	if (my_selected) {
		CGContextSetRGBFillColor(c, 0.2, 0.2, 0.2, 1);
	} else {
		CGContextSetRGBFillColor(c, 0, 0, 0, 1);
	}
	CGContextFillRect(c, rect);
	
	/* Divider line */
	CGContextSetRGBStrokeColor(c, 154/255.0, 154/255.0, 154/255.0, 1);
	CGContextMoveToPoint(c, 0, rect.size.height-1);
	CGContextAddLineToPoint(c, rect.size.width-1, rect.size.height-1);
	CGContextStrokePath(c);
		
	/* Draw level # */
	CGContextSetRGBFillColor(c, 1, 1, 1, 1);
	[[NSString stringWithFormat:@"%s",display_names[level]]
		drawInRect:CGRectMake(0, 30, 40, 20)
		withFont:Bsys16
		lineBreakMode:UILineBreakModeWordWrap
		alignment:UITextAlignmentCenter];
	
	/* Completed or not? */
	CGContextSetRGBFillColor(c, 1, 1, 1, 1);
	if ([GameStateModel getLevelCompleted:level]) {
		CGContextSetRGBFillColor(c, 0, 1, 0, 1);
		[@"Completed" drawInRect:CGRectMake(168, 10, 100, 20) withFont:Bsys12];
	} else {		
		[@"Not Completed" drawInRect:CGRectMake(168, 10, 100, 20) withFont:Bsys12];
	}
	CGContextSetRGBFillColor(c, 1, 1, 1, 1);
	
	/* Designed by */
	[@"Designed by:" drawInRect:CGRectMake(168, 40, 100, 20) withFont:sys12];
	[map_model.author drawInRect:CGRectMake(168, 55, 100, 20) withFont:sys12]; 
	
	/* Badges */
	int badge = [GameStateModel getLevelBadge:level];
	if (badge > 0) {
		[img_badges[badge-1] drawInRect:CGRectMake(230, 5, 30, 30)];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	//[super setSelected:selected animated:animated];
	my_selected = selected;
	[self setNeedsDisplay];
	// Configure the view for the selected state
}


- (void)dealloc {
	[super dealloc];
}


@end
