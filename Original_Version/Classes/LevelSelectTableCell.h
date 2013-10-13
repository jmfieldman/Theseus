//
//  LevelSelectTableCell.h
//  Theseus
//
//  Created by Jason Fieldman on 9/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapGenerator.h"
#import "MapModel.h"
#import "MapView.h"

#define kRecentGameCellHeight 80

@interface LevelSelectTableCell : UITableViewCell {
	int level;
	
	MapModel *map_model;
	MapView *map_view;
	
	BOOL my_selected;
}

- (id) initWithLevel:(int)i;

@end
