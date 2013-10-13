//
//  StatusBarView.h
//  Theseus
//
//  Created by Jason Fieldman on 12/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapModel.h"

#define kStatusBarAppearDuration 0.5
#define kStatusBarHeight 20.0

#define kStatusBarLabelY 0.0
#define kStatusBarLabelH 16.0

#define kStatusBarLabelNameX 10.0
#define kStatusBarLabelNameW 110.0

#define kStatusBarLabelMovesX 130.0
#define kStatusBarLabelMovesW 110.0

#define kStatusBarLabelBMovesX 250.0
#define kStatusBarLabelBMovesW 110.0

#define kStatusBarLabelAwardX 300.0
#define kStatusBarLabelAwardY 2.0
#define kStatusBarLabelAwardS 16.0

#define kStatusBarFontFamily @"Trebuchet MS"
#define kStatusBarFontSize 12.0

@interface StatusBarView : UIView {
	UILabel *label_name;
	UILabel *label_moves;
	UILabel *label_bestmoves;
	
	UIImageView *award_img;	
	
	BOOL appeared;
}

- (void)appear:(BOOL)appear;

- (void)setName:(NSString*)name;
- (void)setMoves:(int)moves outOf:(int)goldMoves;
- (void)setBestMoves:(int)bmoves;
- (void)setAward:(int)award_level;

- (void)updateForModel:(MapModel*)model;

@end
