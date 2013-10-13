//
//  ConvertibleImageView.h
//  Theseus
//
//  Created by Jason Fieldman on 12/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ConvertibleImageView : UIView {
	UIImageView *activeImageView;
	UIImageView *incomingImageView;
}

- (void)setActiveImage:(UIImage*)img;
- (void)setIncomingImage:(UIImage*)img;
- (void)resizeTo:(int)side;

- (void)rotateIntoNewImage:(UIImage*)img duration:(float)dur delay:(float)del withAlpha:(BOOL)a;
- (void)gearsToNewImage:(UIImage*)img duration:(float)dur delay:(float)del;
- (void)replaceNewImageOver:(UIImage*)img delay:(float)del;

@end
