//
//  ConvertibleImageView.m
//  Theseus
//
//  Created by Jason Fieldman on 12/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ConvertibleImageView.h"
#import "DataStructures.h"
#import "TileHelper.h"

@implementation ConvertibleImageView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		activeImageView = nil;
		incomingImageView = nil;		
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setActiveImage:(UIImage*)img {
	[activeImageView removeFromSuperview];
	
	activeImageView = [[UIImageView alloc] initWithImage:img];
	activeImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[self addSubview:activeImageView];
	[self bringSubviewToFront:activeImageView];
	[activeImageView release];	
}

- (void)setIncomingImage:(UIImage*)img {
	[incomingImageView removeFromSuperview];
	
	incomingImageView = [[UIImageView alloc] initWithImage:img];
	incomingImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[self addSubview:incomingImageView];
	[self sendSubviewToBack:incomingImageView];
	[incomingImageView release];	
}

- (void)resizeTo:(int)side {
	CGRect r = CGRectMake(0, 0, side, side);
	if (activeImageView) activeImageView.frame = r;
	if (incomingImageView) incomingImageView.frame = r;
	self.frame = r;
}

- (void)_handleRotateTimer:(NSTimer*)timer {
	if (incomingImageView) {
		[activeImageView removeFromSuperview];
		activeImageView = incomingImageView;
		incomingImageView = nil;
	}
}

- (void)rotateIntoNewImage:(UIImage*)img duration:(float)dur delay:(float)del withAlpha:(BOOL)a {
	[self setIncomingImage:img];
	
	if (a) { incomingImageView.alpha = 0; }
	
	incomingImageView.layer.transform = g_rotateThreeQuarters;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:dur];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDelay:del];
	incomingImageView.layer.transform = g_rotateIdentity;
	activeImageView.layer.transform = g_rotateQuarter;
	if (a) { incomingImageView.alpha = 1; activeImageView.alpha = 0; }
	[UIView commitAnimations];
	
	if (a) { START_TIMER(dur+del, _handleRotateTimer:, NO); }
	if (!a) [self _handleRotateTimer:nil];
}

- (void)gearsToNewImage:(UIImage*)img duration:(float)dur delay:(float)del {
	[self setIncomingImage:img];
	
	int w = incomingImageView.frame.size.width;
	int h = incomingImageView.frame.size.height;
	float dur_half = dur / 2.0;
	
	CGRect tinyRect = CGRectMake(w/2, h/2, 1, 1);
	CGRect normalRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	incomingImageView.frame = tinyRect;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:dur_half];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDelay:del];
	incomingImageView.frame = normalRect;
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:dur_half];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDelay:(del+dur_half)];
	activeImageView.frame = tinyRect;
	[UIView commitAnimations];
	
	START_TIMER(dur+del+0.05, _handleRotateTimer:, NO);
}

- (void)_handleReplaceTimer:(NSTimer*)timer {
	if (incomingImageView) {
		[activeImageView removeFromSuperview];
		activeImageView = incomingImageView;
		incomingImageView = nil;
		activeImageView.alpha = 1;
	}
}

- (void)replaceNewImageOver:(UIImage*)img delay:(float)del {
	[self setIncomingImage:img];
	incomingImageView.alpha = 0;
	
	START_TIMER(del, _handleReplaceTimer:, NO);
}

@end
