//
//  TutorialView.m
//  Theseus
//
//  Created by Jason Fieldman on 12/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TutorialView.h"
#import "DataStructures.h"

@implementation TutorialView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		appeared = NO;
		
		background_img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial.png"]];
		background_img.frame = CGRectMake(0, 0, 320, 160);
		[self addSubview:background_img];
		
		label_title = [[UILabel alloc] initWithFrame:CGRectMake(17,6,121,22)];
		label_title.backgroundColor = [UIColor clearColor];
		label_title.font = [UIFont fontWithName:@"Trebuchet MS" size:16];
		label_title.text = JFLocalizedString(@"TutorialTitle", @"Tutorial");
		label_title.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label_title];
		
		scroll_font = [[UIFont fontWithName:@"Trebuchet MS" size:12] retain];
		
		scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(9, 32, 300, 119)];
		scroll_view.backgroundColor = [UIColor clearColor];
		scroll_view.delegate = self;
		[self addSubview:scroll_view];
		
		/* quote = [[UILabel alloc] initWithFrame:CGRectMake(0,0,420,52)];
		 quote.font = slabelFont;
		 quote.backgroundColor = [UIColor clearColor];
		 quote.lineBreakMode = UILineBreakModeWordWrap;
		 quote.numberOfLines = 0;
		 quote.adjustsFontSizeToFitWidth = NO; */
		
		scroll_text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 119)];
		scroll_text.font = scroll_font;
		scroll_text.backgroundColor = [UIColor clearColor];
		scroll_text.lineBreakMode = NSLineBreakByWordWrapping;
		scroll_text.numberOfLines = 0;
		scroll_text.adjustsFontSizeToFitWidth = NO;
		[scroll_view addSubview:scroll_text];
		
		tutorial_indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_arrow.png"]];
		tutorial_indicator.frame = CGRectMake(200, 100, 100, 20);
		tutorial_indicator.hidden = YES;
		[scroll_view addSubview:tutorial_indicator];
		[tutorial_indicator release];
		
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	tutorial_indicator.hidden = YES;
}

- (void)startIndicator {
	tutorial_indicator.hidden = NO;
	tutorial_indicator.alpha = 1;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:1];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationRepeatCount:10];
	[UIView setAnimationRepeatAutoreverses:YES];
	tutorial_indicator.alpha = 0;
	[UIView commitAnimations];
}

- (void)updateTextForLevel:(int)level {
	if (level > 3) return;
	NSString *tut_lab = [NSString stringWithFormat:@"Tutorial%d",level];
	NSString *my_text = JFLocalizedString(tut_lab, @"No tutorial is available for the current langugage setting.");
	
	/* 	NSString *qt = [dict objectForKey:@"quote"];
	 CGSize s = [qt sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(420, 1000) lineBreakMode:UILineBreakModeWordWrap];
	 */
	
	CGSize s = [my_text sizeWithFont:scroll_font constrainedToSize:CGSizeMake(295,10000) lineBreakMode:NSLineBreakByWordWrapping];
	
	NSLog(@"size: %f %f", s.width, s.height);

	CGRect tr = scroll_text.frame;
	tr.size.height = s.height;
	scroll_text.frame = tr;
	scroll_text.text = my_text;
	
	scroll_view.contentSize = s;

	scroll_view.contentOffset = CGPointZero;
	[self startIndicator];
}

- (void)_handleDisappearTimer:(NSTimer*)timer {
	self.hidden = YES;
}

- (void) appear:(BOOL)appear {
	if (appear) {
		if (appeared) return;
		appeared = YES;
		self.alpha = 0;
		self.hidden = NO;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kTutorialFlourishDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		self.alpha = 1;
		[UIView commitAnimations];
	} else {
		if (!appeared) return;
		appeared = NO;
		self.alpha = 1;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kTutorialFlourishDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		self.alpha = 0;
		[UIView commitAnimations];
		START_TIMER(kTutorialFlourishDuration, _handleDisappearTimer:, NO);
	}
}

@end
