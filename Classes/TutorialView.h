//
//  TutorialView.h
//  Theseus
//
//  Created by Jason Fieldman on 12/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTutorialFlourishDuration 0.5

@interface TutorialView : UIView <UIScrollViewDelegate> {
	UIImageView *background_img;
	UIImageView *tutorial_indicator;
	
	UILabel *label_title;
	
	UIFont *scroll_font;
	UIScrollView *scroll_view;
	UILabel *scroll_text;
	
	BOOL appeared;
}

- (void) appear:(BOOL)appear;
- (void)updateTextForLevel:(int)level;

@end
