//
//  CreditsView.h
//  Theseus
//
//  Created by Jason Fieldman on 12/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCreditsFlourishDuration 0.25

@interface CreditsView : UIView {
	UIImageView *backgnd;
	
	UILabel *content;
}

- (void) appear:(BOOL)appear;

@end
