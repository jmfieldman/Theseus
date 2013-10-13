//
//  TheseusAppDelegate.h
//  Theseus
//
//  Created by Jason Fieldman on 8/25/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationHelperModel.h"

@class TheseusViewController;

@interface TheseusAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) UIWindow *window;

@end

