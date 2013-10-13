//
//  CreditsView.m
//  Theseus
//
//  Created by Jason Fieldman on 12/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CreditsView.h"
#import "SoundManager.h"
#import "DataStructures.h"

@implementation CreditsView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		
		/* Background */
		backgnd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"credits_bubble.png"]];
		backgnd.frame = CGRectMake(0, 0, self.frame.size.width, 568);//self.frame.size.height);
		[self addSubview:backgnd];
		[backgnd release];
		
		content = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, 240, 370)];
		content.text = JFLocalizedString(@"InfoText", @"Not available in this language.");
		
		UIFont *cont_font = [UIFont fontWithName:@"Trebuchet MS" size:11];
		
		content.font = cont_font;
		content.backgroundColor = [UIColor clearColor];
		content.numberOfLines = 0;
		
		CGSize s;
		CGRect tr;
		
		s = [content.text sizeWithFont:cont_font constrainedToSize:CGSizeMake(240,10000) lineBreakMode:NSLineBreakByWordWrapping];
		tr = content.frame;
		tr.size.height = s.height;
		content.frame = tr;
		
		[self addSubview:content];
		[content release];
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}

- (void)_handleDisappearTimer:(NSTimer*)timer {
	self.hidden = YES;
}

- (void) appear:(BOOL)appear {
	if (appear) {
		self.alpha = 0;
		self.hidden = NO;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kCreditsFlourishDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		self.alpha = 1;
		[UIView commitAnimations];
		[SoundManager playSound:SND_TONGUE];
	} else {
		self.alpha = 1;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kCreditsFlourishDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		self.alpha = 0;
		[UIView commitAnimations];
		[SoundManager playSound:SND_TONGUE];
		START_TIMER(kCreditsFlourishDuration, _handleDisappearTimer:, NO);
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];
	
	if (num_touches) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		if (p.x > 245 && p.y < 75) {
			[self appear:NO];
		}
	}
}

@end
