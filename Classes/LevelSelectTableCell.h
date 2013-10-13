//
//  LevelSelectTableCell.h
//  Theseus
//
//  Created by Jason Fieldman on 12/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapModel.h"
#import "MapGenerator.h"
#import "MapView.h"
#import "MapPreviewView.h"

#define kLevelSelectTableCellHeight 80.0

@interface LevelSelectTableCell : UITableViewCell {
	MapModel *map_model;
	MapPreviewView *preview_view;
	MapPreviewView *preview_view_alpha;
	
	int prev_w, prev_h, prev_x, prev_y;
	
	/* Stats and stuff */
	UILabel *label_title;
	UILabel *label_designer;
	UILabel *label_solved;
	UIImageView *img_award;
}

- (id) initWithLevel:(int)level;
- (void) updateDisplay;

@end
