//
//  LevelSelectTableCell.m
//  Theseus
//
//  Created by Jason Fieldman on 12/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LevelSelectTableCell.h"
#import "DataStructures.h"
#import "TileHelper.h"
#import "MapGenerator.h"
#import "GameStateModel.h"

@implementation LevelSelectTableCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (id) initWithLevel:(int)level {
	if (self = [self initWithFrame:CGRectZero reuseIdentifier:nil]) {
		map_model = [MapGenerator getMap:level];

		prev_w = map_model.size.w * 8;
		prev_h = map_model.size.h * 8;
		
		if (map_model.size.w > 8) {
			prev_w = map_model.size.w * 6;
			prev_h = map_model.size.h * 6;
		}
		
		prev_x = 50-prev_w/2;
		prev_y = 38-prev_h/2;

		preview_view = [[MapPreviewView alloc] initWithFrame:CGRectMake(prev_x,prev_y,prev_w,prev_h) withMap:map_model withBorder:0];
		[self addSubview:preview_view];

		preview_view_alpha = [[MapPreviewView alloc] initWithFrame:CGRectMake(prev_x,prev_y,prev_w,prev_h) withMap:map_model withBorder:0];
		preview_view_alpha.alpha = 0.5;
		[self addSubview:preview_view_alpha];
		
		/* stats and stuff */
		label_title    = [[UILabel alloc] initWithFrame:CGRectMake(105, 10, 200, 20)];
		label_designer = [[UILabel alloc] initWithFrame:CGRectMake(105, 32, 200, 20)];;
		label_solved   = [[UILabel alloc] initWithFrame:CGRectMake(105, 50, 200, 20)];;
		
		label_title.backgroundColor = label_designer.backgroundColor = label_solved.backgroundColor = [UIColor clearColor];
		label_title.font    = [UIFont fontWithName:@"Trebuchet MS" size:20];
		label_designer.font = [UIFont fontWithName:@"Trebuchet MS" size:12];
		label_solved.font   = [UIFont fontWithName:@"Trebuchet MS" size:12];
		
		img_award      = [[UIImageView alloc] initWithImage:g_goldaward];
		img_award.frame = CGRectMake(260, 20, 40, 40);
		img_award.hidden = YES;
		
		[self addSubview:label_title];    [label_title release];
		[self addSubview:label_designer]; [label_designer release];
		[self addSubview:label_solved];   [label_solved release];
		[self addSubview:img_award];      [img_award release];
		
		
		[self updateDisplay];
	}
	return self;	
}

- (void) drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	/* gradient? */
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { 1.0, 1.0, 1.0, 1.0,  // Start color		
//							  255/255.0, 246/255.0, 221/255.0, 1.0 }; // End color
							  236/255.0, 231/255.0, 226/255.0, 1.0 }; // End color
		
	myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,													  
													  locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;	
	myStartPoint.x = 0.0;	
	myStartPoint.y = 70.0;	
	myEndPoint.x = 0.0;	
	myEndPoint.y = self.frame.size.height;	
	CGContextDrawLinearGradient (c, myGradient, myStartPoint, myEndPoint, 0);
	CGColorSpaceRelease(myColorspace);
	CGGradientRelease(myGradient);
	
	/* preview shadow */
	CGContextSetShadow(c, CGSizeMake(2, -2), 5);
	CGContextSetRGBFillColor(c, 0, 0, 0, 1);
	CGContextFillRect(c, CGRectMake(prev_x, prev_y, prev_w, prev_h));
	
	/* Divider line */
	CGContextSetRGBStrokeColor(c, 220/255.0, 220/255.0, 220/255.0, 1);
	CGContextMoveToPoint(c, 0, rect.size.height-1);
	CGContextAddLineToPoint(c, rect.size.width-1, rect.size.height-1);
	CGContextStrokePath(c);
}

- (void) updateDisplay {
	label_title.text = [NSString stringWithFormat:@"%@ %@", JFLocalizedString(@"LevelLabel", @"Level"), [NSString stringWithUTF8String:display_names[map_model.maze_level]]];
	label_designer.text = [NSString stringWithFormat:@"%@ %@", JFLocalizedString(@"DesignedBy", @"Designed by"), map_model.author];
	
	/*
	 "NotYet" = "Not yet solved";
	 "MovesLevelSel" = "moves";
	 "SolvedIn" = "Solved in"
	*/
	
	if ([GameStateModel getBestNumMoves:map_model.maze_level] == 0) {
		if ([GameStateModel getLevelBadge:map_model.maze_level] || [GameStateModel getLevelCompleted:map_model.maze_level]) {
			if ([GameStateModel getLevelBadge:map_model.maze_level] == 3) {
				/* Gold medal */
				[GameStateModel setBestNumMoves:map_model.maze_level moves:map_model.best_move_pos];
				goto moves_discovered;
			}
			
			label_solved.text = [NSString stringWithFormat:@"%@ [?]/%d %@",
									JFLocalizedString(@"SolvedIn", @"Solved in"),
									map_model.best_move_pos,
									JFLocalizedString(@"MovesLevelSel", @"moves")];
		} else {
			label_solved.text = [NSString stringWithFormat:@"%@ (%d %@)",
								 JFLocalizedString(@"NotYet", @"Not yet solved"),
								 map_model.best_move_pos,
								 JFLocalizedString(@"MovesLevelSel", @"moves")];			
		}
	} else {
moves_discovered:
		{
		int cbm = [GameStateModel getBestNumMoves:map_model.maze_level];
		label_solved.text = [NSString stringWithFormat:@"%@ %d/%d %@",
							 JFLocalizedString(@"SolvedIn", @"Solved in"),
							 (map_model.best_move_pos > cbm) ? map_model.best_move_pos : cbm,
							 map_model.best_move_pos,
							 JFLocalizedString(@"MovesLevelSel", @"moves")];
		}
	}
	
	int my_badge = [GameStateModel getLevelBadge:map_model.maze_level];
	if (!my_badge && [GameStateModel getLevelCompleted:map_model.maze_level]) {
		my_badge = 2;
	}
	
	if (my_badge) {
		img_award.hidden = NO;
		img_award.image = (my_badge == 3) ? g_goldaward : g_silvaward;
	} else {
		img_award.hidden = YES;
	}
}

- (void)handleSizeReset:(NSTimer*)timer {
	[preview_view_alpha updateWithFrame:CGRectMake(prev_x, prev_y, prev_w, prev_h) withMap:map_model withBorder:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    //[super setSelected:selected animated:animated];

	if (selected) {
		int a_prev_w = map_model.size.w * 24;
		int a_prev_h = map_model.size.h * 24;
		int a_prev_x = 50-a_prev_w/2;
		int a_prev_y = 38-a_prev_h/2;
		
		const float del = 0.25;
		
		preview_view_alpha.alpha = 1;
		[preview_view_alpha updateWithFrame:CGRectMake(prev_x, prev_y, prev_w, prev_h) withMap:map_model withBorder:0];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:del];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[preview_view_alpha updateWithFrame:CGRectMake(a_prev_x, a_prev_y, a_prev_w, a_prev_h) withMap:map_model withBorder:0];		
		preview_view_alpha.alpha = 0;
		[UIView commitAnimations];
		
		START_TIMER( (del*2), handleSizeReset:, NO);
		
	}

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
