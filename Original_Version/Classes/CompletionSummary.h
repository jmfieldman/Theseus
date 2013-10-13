//
//  CompletionSummary.h
//  Theseus
//
//  Created by Jason Fieldman on 12/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStructures.h"

@interface CompletionSummary : UIView {
	UIImageView *backgnd;

	UILabel *label_menu;
	UILabel *label_next;
	UILabel *label_replay;
	
	id<DungeonNavigationDelegate> navDelegate;
}

@property (retain) id<DungeonNavigationDelegate> navDelegate;

@end
