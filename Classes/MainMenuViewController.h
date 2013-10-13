//
//  MainMenuViewController.h
//  Theseus
//
//  Created by Jason Fieldman on 12/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreditsView.h"

#define kMenuHeaderHeight 70.0

#define kHeaderPopDuration 0.5

#define kCellAlphaDuration 0.6
#define kCellAlphaStagger 0.1

@interface MainMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UIView *contentView;
	
	UIView *headerView;
	
	/* Table */
	UITableView *table_levels;
	NSMutableArray *array_levels;
	
	/* Flourish state */
	BOOL flourished_in;

	/* Info button */
	UIButton *info_button;
	CreditsView *cred_view;
}

+ (MainMenuViewController*) sharedInstance;

- (void)flourishIn;
- (void)flourishOut;

- (void)updateCellForLevel:(int)level;

@end
