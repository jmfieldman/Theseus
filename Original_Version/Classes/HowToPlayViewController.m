//
//  HowToPlayViewController.m
//  Theseus
//
//  Created by Jason Fieldman on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HowToPlayViewController.h"
#import "GraphicsModel.h"

#define SCROLL_W 300
#define SCROLL_H 509

@implementation HowToPlayViewController

- (id)init {
	self = [super init];
	if (self) {
		UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,20,320,460)];
		contentView.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1];
		//contentView.backgroundColor = [UIColor blackColor];
		self.view = contentView;
		[contentView release];
		
		UIImageView *bck_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
		bck_view.image = img_howto_bk;
		[contentView addSubview:bck_view];
		
		exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		exitButton.frame = CGRectMake(0,0,40,40);
		exitButton.backgroundColor = [UIColor clearColor];
		[exitButton setBackgroundImage:img_close_button forState:UIControlStateNormal];	
		[exitButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[contentView addSubview:exitButton];
		
		title = [[UILabel alloc] initWithFrame:CGRectMake(60, 1, 200, 19)];
		title.backgroundColor = [UIColor clearColor];
		title.text = @"How To Play";
		title.textColor = [UIColor whiteColor];
		title.font = sys16;
		title.textAlignment = UITextAlignmentCenter;
		[contentView addSubview:title];
		
		exitButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
		exitButton2.frame = CGRectMake(10,400,300,50);
		exitButton2.backgroundColor = [UIColor clearColor];
		exitButton2.font = sys14;
		[exitButton2 setBackgroundImage:[img_button_wait stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateNormal];
		[exitButton2 setBackgroundImage:[img_button_wait_dn stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateHighlighted];
		[exitButton2 setTitle:@"Return To Main Menu" forState:UIControlStateNormal];
		[exitButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[exitButton2 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
		[contentView addSubview:exitButton2];
		
		UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(10,20,300,370)];
		scrollview.backgroundColor = [UIColor blackColor];
		scrollview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		scrollview.scrollEnabled = YES;
		scrollview.contentSize = CGSizeMake(SCROLL_W, img_howto_con.size.height);
		scrollview.showsVerticalScrollIndicator = NO;
		[self.view addSubview:scrollview];
		[scrollview release];
		
		UIImageView *sbck_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCROLL_W, img_howto_con.size.height)];
		sbck_view.image = img_howto_con;
		[scrollview addSubview:sbck_view];
		
	}	
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */

- (void)buttonAction:(id)sender {
	if (sender == exitButton || sender == exitButton2) {
		[[self navigationController] popViewControllerAnimated:YES];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end
