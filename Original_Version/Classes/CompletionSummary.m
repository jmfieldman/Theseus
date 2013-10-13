//
//  CompletionSummary.m
//  Theseus
//
//  Created by Jason Fieldman on 12/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CompletionSummary.h"


@implementation CompletionSummary
@synthesize navDelegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		navDelegate = nil;
		
		backgnd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"
    }
    return self;
}




- (void)dealloc {
	[navDelegate release];
    [super dealloc];
}


@end
