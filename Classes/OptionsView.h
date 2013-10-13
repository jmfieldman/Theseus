//
//  OptionsView.h
//  Theseus
//
//  Created by Jason Fieldman on 12/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	OPT_SOUND,
	OPT_IDLE,
	OPT_HINT,
	OPT_RHAND,
} Options_t;

@protocol OptionsDelegate <NSObject>
@required
- (void) acceptOptionsChange:(Options_t)option newValue:(BOOL)value;
@end

#define kOptionsFlourishDuration 0.25

#define kYOffset 100.0
#define kYStart 33.0

#define kSoundMult 0
#define kIdleMult  1
#define kHintMult  2
#define kHandMult  3

#define kSliderXOff 50.0
#define kSliderYOff 10.0

#define kTitleX 155.0
#define kTitleY 8.0
#define kTitleW 140.0
#define kTitleH 30.0

#define kDescX 75.0
#define kDescY 45.0
#define kDescW 190.0
#define kDescH 48.0

#define kRectSlider(_mult) CGRectMake(kSliderXOff, kYStart + (kYOffset* _mult) + kSliderYOff, 50, 30)
#define kRectTitle(_mult)  CGRectMake(kTitleX, kYStart + (kYOffset* _mult) + kTitleY, kTitleW, kTitleH)
#define kRectDesc(_mult)   CGRectMake(kDescX, kYStart + (kYOffset* _mult) + kDescY, kDescW, kDescH)

#define OptAllTitles(_param) title_hint._param = title_sound._param = title_idle._param = title_rhand._param
#define OptAllDesc(_param)   desc_hint._param = desc_sound._param = desc_idle._param = desc_rhand._param

@interface OptionsView : UIView {
	UIImageView *backgnd;
	
	UISwitch *slider_sound;
	UISwitch *slider_idle;
	UISwitch *slider_hint;
	UISwitch *slider_rhand;
	
	UILabel *title_sound;
	UILabel *title_idle;
	UILabel *title_hint;
	UILabel *title_rhand;
	
	UILabel *desc_sound;
	UILabel *desc_idle;
	UILabel *desc_hint;
	UILabel *desc_rhand;
	
	id<OptionsDelegate> optDelegate;
}

@property (retain) id<OptionsDelegate> optDelegate;

- (void) appear:(BOOL)appear;

@end
