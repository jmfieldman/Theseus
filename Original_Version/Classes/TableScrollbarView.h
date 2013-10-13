//
//  TableScrollbarView.h
//  Theseus
//
//  Created by Jason Fieldman on 9/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableScrollbarDelegate <NSObject>
@required
- (void)acceptTableScroll:(BOOL)page_move pageUp:(BOOL)pu position:(double)pos;
@end

#define SLIDER_UNSEL 255/255.0, 255/255.0, 255/255.0, 1
#define SLIDER_SEL   245/255.0, 235/255.0, 225/255.0, 1

#define SLIDER_HEIGHT 75

#define BAR_UNSEL  64/255.0, 64/255.0, 64/255.0, 1
#define BAR_SEL    192/255.0, 192/255.0, 192/255.0, 1

@interface TableScrollbarView : UIView {
	int my_width;
	int my_height;
	int my_radius;
	int my_pos;
	
	int which_selecting;
	int which_down;
	
	id<TableScrollbarDelegate> scrollDelegate;
	double start_drag_y;
}

- (void)updateWithScroll:(UIScrollView *)view;

@property (assign) id<TableScrollbarDelegate> scrollDelegate;

@end
