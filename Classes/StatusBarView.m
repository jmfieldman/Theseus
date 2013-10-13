//
//  StatusBarView.m
//  Theseus
//
//  Created by Jason Fieldman on 12/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StatusBarView.h"
#import "MapGenerator.h"
#import "GameStateModel.h"

@implementation StatusBarView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		appeared = NO;
		
		label_name = [[UILabel alloc] initWithFrame:CGRectMake(kStatusBarLabelNameX, kStatusBarLabelY, kStatusBarLabelNameW, kStatusBarLabelH)];
		label_name.font = [UIFont boldSystemFontOfSize:kStatusBarFontSize];
		[self addSubview:label_name];
		[label_name release];
		
		label_moves = [[UILabel alloc] initWithFrame:CGRectMake(kStatusBarLabelMovesX, kStatusBarLabelY, kStatusBarLabelMovesW, kStatusBarLabelH)];		
		label_moves.font = [UIFont boldSystemFontOfSize:kStatusBarFontSize];
		[self addSubview:label_moves];
		[label_moves release];

		label_bestmoves = [[UILabel alloc] initWithFrame:CGRectMake(kStatusBarLabelBMovesX, kStatusBarLabelY, kStatusBarLabelBMovesW, kStatusBarLabelH)];
		label_bestmoves.font = [UIFont boldSystemFontOfSize:kStatusBarFontSize];
		[self addSubview:label_bestmoves];
		[label_bestmoves release];
		
		award_img = [[UIImageView alloc] initWithFrame:CGRectMake(kStatusBarLabelAwardX, kStatusBarLabelAwardY, kStatusBarLabelAwardS, kStatusBarLabelAwardS)];
		[self addSubview:award_img];
		[award_img release];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)appear:(BOOL)appear {
	if (appear && appeared) return;
	if (!appear && !appeared) return;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView	setAnimationDuration:kStatusBarAppearDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	CGPoint c = self.center;
	if (appear) c.y += kStatusBarHeight; else c.y -= kStatusBarHeight;
	self.center = c;
	[UIView commitAnimations];
	
	appeared = appear;
}

- (void)setName:(NSString*)name {
	label_name.text = [NSString stringWithFormat:@"%@: %@", JFLocalizedString(@"LevelLabel", @"Level"), name];
}

- (void)setMoves:(int)moves outOf:(int)goldMoves {
	label_moves.text = [NSString stringWithFormat:@"%@: %d/%d", JFLocalizedString(@"MovesLabel", @"Moves"), moves, goldMoves];
}

- (void)setBestMoves:(int)bmoves {
	if (bmoves > 0) {
		label_bestmoves.text = [NSString stringWithFormat:@"%@: %d", JFLocalizedString(@"BestLabel", @"Best"), bmoves];
	} else {
		label_bestmoves.text = [NSString stringWithFormat:@"%@: --", JFLocalizedString(@"BestLabel", @"Best")];
	}
}

- (void)setAward:(int)award_level {
	
}

- (void)updateForModel:(MapModel*)model {
	[self setName:[NSString stringWithUTF8String:display_names[model.maze_level]]];
	[self setMoves:model.history_cursor outOf:model.best_move_pos];
	
	int cbm = [GameStateModel getBestNumMoves:model.maze_level];
	[self setBestMoves:( (model.best_move_pos > cbm && cbm != 0) ? model.best_move_pos : cbm )];
}

@end
