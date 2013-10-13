//
//  CompletionSummary.m
//  Theseus
//
//  Created by Jason Fieldman on 12/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CompletionSummary.h"
#import "SoundManager.h"
#import "TileHelper.h"

@implementation CompletionSummary
@synthesize navDelegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		navDelegate = nil;
		self.userInteractionEnabled = YES;
		
		/* Background */
		backgnd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_box.png"]];
		backgnd.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
		[self addSubview:backgnd];
		[backgnd release];
		
		/* Button labels */
		label_menu   = [[UILabel alloc] initWithFrame:kCompLabMenuRect];
		label_next   = [[UILabel alloc] initWithFrame:kCompLabNextRect];
		label_replay = [[UILabel alloc] initWithFrame:kCompLabReplRect];
		
		label_menu.font = label_next.font = label_replay.font = kCompLabFont;
		label_menu.backgroundColor = label_next.backgroundColor = label_replay.backgroundColor = [UIColor clearColor];
		label_menu.textAlignment = label_next.textAlignment = label_replay.textAlignment = UITextAlignmentCenter;
		label_menu.textColor = label_next.textColor = label_replay.textColor = [UIColor blackColor];
		label_menu.userInteractionEnabled = label_next.userInteractionEnabled = label_replay.userInteractionEnabled = NO;
		label_menu.shadowColor = label_next.shadowColor = label_replay.shadowColor = [UIColor whiteColor];
		label_menu.shadowOffset = label_next.shadowOffset = label_replay.shadowOffset = CGSizeMake(1,1);
		
		label_menu.text   = JFLocalizedString(@"CompMenuLabel", @"Main Menu");
		label_next.text   = JFLocalizedString(@"CompNextLabel", @"Next Level"); 
		label_replay.text = JFLocalizedString(@"CompReplayLabel", @"Replay");
		
		//"CompMenuLabel" = "Main Menu";
		//"CompNextLabel" = "Next Level";
		//"CompReplayLabel" = "Replay";
		
		[self addSubview:label_menu];
		[self addSubview:label_next];
		[self addSubview:label_replay];
		
		/* Other labels */
		label_complete = [[UILabel alloc] initWithFrame:CGRectMake(0, 132, self.frame.size.width, 30)];
		label_moves =    [[UILabel alloc] initWithFrame:CGRectMake(0, 165, self.frame.size.width, 30)];
		img_award      = [[UIImageView alloc] initWithImage:g_goldaward];
		img_award.frame = CGRectMake(145, 164, 30, 30);
		
		label_complete.backgroundColor = label_moves.backgroundColor = [UIColor clearColor];
		label_complete.text = JFLocalizedString(@"CompTitle", @"Level Complete!");
		label_complete.textAlignment = UITextAlignmentCenter;
		label_moves.textAlignment = UITextAlignmentCenter;
		
		label_complete.font = [UIFont fontWithName:@"Trebuchet MS" size:24];
		label_complete.textColor = [UIColor whiteColor];
		label_complete.shadowColor = [UIColor blackColor];
		label_complete.shadowOffset = CGSizeMake(1,1);
		
		[self addSubview:label_complete];
		[self addSubview:img_award];
		//[self addSubview:label_moves];
		
    }
    return self;
}

- (void)dealloc {
	[navDelegate release];
    [super dealloc];
}

- (void)_handleDisappearTimer:(NSTimer*)timer {
	self.hidden = YES;
}

- (void)updateForModel:(MapModel*)model {
	label_moves.text = [NSString stringWithFormat:@"%d/%d %@:", model.history_cursor, model.best_move_pos, JFLocalizedString(@"CompSubtitle", @"moves")];
	if (model.history_cursor <= model.best_move_pos) {
		img_award.image = g_goldaward;
	} else {
		img_award.image = g_silvaward;
	}
}

- (void) appear:(BOOL)appear {
	if (appear) {
		self.alpha = 0;
		self.hidden = NO;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kCompStatFlourishDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		self.alpha = 1;
		[UIView commitAnimations];
		[SoundManager playSound:SND_VAULT];
	} else {
		self.alpha = 1;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kCompStatFlourishDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		self.alpha = 0;
		[UIView commitAnimations];
		START_TIMER(kCompStatFlourishDuration, _handleDisappearTimer:, NO);
	}
}

- (void)_handleButMenu:(NSTimer*)timer {
	[navDelegate acceptNavigation:DNAV_EXIT_TO_MAIN];
}

- (void)_handleButReset:(NSTimer*)timer {
	[navDelegate acceptNavigation:DNAV_RESET_LEVEL];
}

- (void)_handleButNext:(NSTimer*)timer {
	[navDelegate acceptNavigation:DNAV_NEXT_LEVEL];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *myTouches = [[event touchesForView:self] allObjects];
	int num_touches = [myTouches count];
	
	if (num_touches) {
		UITouch *t = [myTouches objectAtIndex:0];
		CGPoint p = [t locationInView:self];
		
		if (p.x > 30 && p.x < 295 && p.y > 190 && p.y < 270) {
			[self appear:NO];
			if (p.x < 115) {				
				START_TIMER(kCompStatFlourishDuration, _handleButMenu:, NO);
			} else if (p.x < 210) {
				START_TIMER(kCompStatFlourishDuration, _handleButNext:, NO);
			} else {
				START_TIMER(kCompStatFlourishDuration, _handleButReset:, NO);
			}
			return;			
		}
	}
}


@end
