//
//  DpadButton.h
//  Theseus
//
//  Created by Jason Fieldman on 12/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStructures.h"

#define DpadSize 120.0
#define DpadMidSize 40.0

@interface DpadButton : UIView {
	UIImageView *dpad;
	UIImageView *dpad_n;
	UIImageView *dpad_s;
	UIImageView *dpad_w;
	UIImageView *dpad_e;
	
	id<DungeonNavigationDelegate> gestureDelegate;
}

@property (retain) id<DungeonNavigationDelegate> gestureDelegate;

- (void) setHighlight:(int)dirs;

@end
