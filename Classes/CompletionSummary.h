//
//  CompletionSummary.h
//  Theseus
//
//  Created by Jason Fieldman on 12/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStructures.h"
#import "MapModel.h"

#define kCompStatFlourishDuration 0.15

#define kCompLabYCoord 240.0
#define kCompLabW      70.0
#define kCompLabH      20.0

#define kCompLabMenuRect CGRectMake(32, kCompLabYCoord, kCompLabW, kCompLabH)
#define kCompLabNextRect CGRectMake(125, kCompLabYCoord, kCompLabW, kCompLabH)
#define kCompLabReplRect CGRectMake(215, kCompLabYCoord, kCompLabW, kCompLabH)
#define kCompLabFont [UIFont fontWithName:@"Trebuchet MS" size:12]

@interface CompletionSummary : UIView {
	UIImageView *backgnd;

	UILabel *label_menu;
	UILabel *label_next;
	UILabel *label_replay;
	
	UILabel *label_complete;
	UILabel *label_moves;
	UIImageView *img_award;
	
	id<DungeonNavigationDelegate> navDelegate;
}

@property (retain) id<DungeonNavigationDelegate> navDelegate;

- (void) appear:(BOOL)appear;
- (void)updateForModel:(MapModel*)model;

@end
