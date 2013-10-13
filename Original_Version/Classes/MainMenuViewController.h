//
//  MainMenuViewController.h
//  Theseus
//
//  Created by Jason Fieldman on 9/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphicsModel.h"
#import "DataStructures.h"
#import "TableScrollbarView.h"

@interface MainMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, TableScrollbarDelegate> {
	/* Table */
	UITableView *table_levels;
	NSMutableArray *array_levels;
	TableScrollbarView *tsv;
	
	/* Level select text */
	UILabel *selectLevelLabel;
	
	/* How to play button */
	UIButton *howToPlayButton;
	
	/* Theseus img */
	UIImageView *theseus_img;
	UIImageView *theseus_shadow;
	UIButton *theseus_button;
	
}

- (void) generateLevelList;
- (void)acceptTableScroll:(BOOL)page_move pageUp:(BOOL)pu position:(double)pos;
- (void) redrawCell:(int)level;
- (void) scrollToLevel:(int)level;

@end
