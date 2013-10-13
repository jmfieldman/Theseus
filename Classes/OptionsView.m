//
//  OptionsView.m
//  Theseus
//
//  Created by Jason Fieldman on 12/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OptionsView.h"
#import "DataStructures.h"
#import "SoundManager.h"
#import "GameStateModel.h"

@implementation OptionsView
@synthesize optDelegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		optDelegate = nil;
		
		/* Background */
		backgnd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"options_bubble.png"]];
		backgnd.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
		[self addSubview:backgnd];
		[backgnd release];
		
		/* Sliders */
		slider_sound = [[UISwitch alloc] initWithFrame:kRectSlider(kSoundMult)];
		slider_idle  = [[UISwitch alloc] initWithFrame:kRectSlider(kIdleMult)];
		slider_hint  = [[UISwitch alloc] initWithFrame:kRectSlider(kHintMult)];
		slider_rhand = [[UISwitch alloc] initWithFrame:kRectSlider(kHandMult)];
		
		[slider_sound addTarget:self action:@selector(_handleSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[slider_idle addTarget:self action:@selector(_handleSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[slider_hint addTarget:self action:@selector(_handleSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[slider_rhand addTarget:self action:@selector(_handleSwitch:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:slider_sound];
		[self addSubview:slider_idle];
		[self addSubview:slider_hint];
		[self addSubview:slider_rhand];
		
		[slider_sound release];
		[slider_idle release];
		[slider_hint release];
		[slider_rhand release];
		
		/* Titles */
		
		title_sound = [[UILabel alloc] initWithFrame:kRectTitle(kSoundMult)];
		title_idle  = [[UILabel alloc] initWithFrame:kRectTitle(kIdleMult)];
		title_hint  = [[UILabel alloc] initWithFrame:kRectTitle(kHintMult)];
		title_rhand = [[UILabel alloc] initWithFrame:kRectTitle(kHandMult)];
		
		title_sound.text = JFLocalizedString(@"OptTitleSound", @"Sound");
		title_idle.text = JFLocalizedString(@"OptTitleIdle", @"Idle Timer");
		title_hint.text = JFLocalizedString(@"OptTitleHint", @"Hint Protection");
		title_rhand.text = JFLocalizedString(@"OptTitleHand", @"Right-Handed");
		
		OptAllTitles(font) = [UIFont fontWithName:@"Trebuchet MS" size:16];
		OptAllTitles(backgroundColor) = [UIColor clearColor];
		
		[self addSubview:title_sound];
		[self addSubview:title_idle];
		[self addSubview:title_hint];
		[self addSubview:title_rhand];
		
		[title_sound release];
		[title_idle release];
		[title_hint release];
		[title_rhand release];
		
		/* Desc */
		
		desc_sound = [[UILabel alloc] initWithFrame:kRectDesc(kSoundMult)];
		desc_idle  = [[UILabel alloc] initWithFrame:kRectDesc(kIdleMult)];
		desc_hint  = [[UILabel alloc] initWithFrame:kRectDesc(kHintMult)];
		desc_rhand = [[UILabel alloc] initWithFrame:kRectDesc(kHandMult)];
		
		desc_sound.text = JFLocalizedString(@"OptDescSound", @"This toggles all in-game sounds ON or OFF.");
		desc_idle.text = JFLocalizedString(@"OptDescIdle", @"Turning this ON allows the iPhone to sleep if you stare at a puzzle for too long.");
		desc_hint.text = JFLocalizedString(@"OptDescHint", @"Turning this ON disables the hint button to prevent you from accidentally pressing it :)");
		desc_rhand.text = JFLocalizedString(@"OptDescHand", @"Turning this ON reorganizes the controls for better use when held with the right hand.");
		
		UIFont *desc_font = [UIFont fontWithName:@"Trebuchet MS" size:12];
		
		OptAllDesc(font) = desc_font;
		OptAllDesc(backgroundColor) = [UIColor clearColor];
		OptAllDesc(numberOfLines) = 0;
		
		CGSize s;
		CGRect tr;
		
		s = [desc_sound.text sizeWithFont:desc_font constrainedToSize:CGSizeMake(kDescW,10000) lineBreakMode:NSLineBreakByWordWrapping];
		tr = desc_sound.frame;
		tr.size.height = s.height;
		desc_sound.frame = tr;
		
		s = [desc_idle.text sizeWithFont:desc_font constrainedToSize:CGSizeMake(kDescW,10000) lineBreakMode:NSLineBreakByWordWrapping];
		tr = desc_idle.frame;
		tr.size.height = s.height;
		desc_idle.frame = tr;
		
		s = [desc_hint.text sizeWithFont:desc_font constrainedToSize:CGSizeMake(kDescW,10000) lineBreakMode:NSLineBreakByWordWrapping];
		tr = desc_hint.frame;
		tr.size.height = s.height;
		desc_hint.frame = tr;
		
		s = [desc_rhand.text sizeWithFont:desc_font constrainedToSize:CGSizeMake(kDescW,10000) lineBreakMode:NSLineBreakByWordWrapping];
		tr = desc_rhand.frame;
		tr.size.height = s.height;
		desc_rhand.frame = tr;
		
		[self addSubview:desc_sound];
		[self addSubview:desc_idle];
		[self addSubview:desc_hint];
		[self addSubview:desc_rhand];
		
		[desc_sound release];
		[desc_idle release];
		[desc_hint release];
		[desc_rhand release];
		
    }
    return self;
}


- (void)dealloc {
	[optDelegate release];
    [super dealloc];
}

- (void)_handleSwitch:(id)sender {	
	UISwitch *s = (UISwitch*)sender;
	if (sender == slider_sound) [optDelegate acceptOptionsChange:OPT_SOUND newValue:s.on];
	if (sender == slider_rhand) [optDelegate acceptOptionsChange:OPT_RHAND newValue:s.on];
	if (sender == slider_hint) [optDelegate acceptOptionsChange:OPT_HINT newValue:s.on];
	if (sender == slider_idle) [optDelegate acceptOptionsChange:OPT_IDLE newValue:s.on];
	[SoundManager playSound:SND_TOGGLE];
}

- (void)_handleDisappearTimer:(NSTimer*)timer {
	self.hidden = YES;
}

- (void) appear:(BOOL)appear {
	if (appear) {
		self.alpha = 0;
		self.hidden = NO;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kOptionsFlourishDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		self.alpha = 1;
		[UIView commitAnimations];
		[SoundManager playSound:SND_TONGUE];
		
		[slider_hint  setOn:(![GameStateModel getHintsActive]) animated:NO];
		[slider_idle  setOn:[GameStateModel getIdleTimer] animated:NO];
		[slider_rhand setOn:[GameStateModel getRightHanded] animated:NO];
		[slider_sound setOn:[SoundManager getGlobalSound] animated:NO];
	} else {
		self.alpha = 1;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kOptionsFlourishDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		self.alpha = 0;
		[UIView commitAnimations];
		[SoundManager playSound:SND_TONGUE];
		START_TIMER(kOptionsFlourishDuration, _handleDisappearTimer:, NO);
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
