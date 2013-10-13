//
//  MainMenuViewController.m
//  Theseus
//
//  Created by Jason Fieldman on 9/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MainMenuViewController.h"
#import "LevelSelectTableCell.h"
#import "DungeonViewController.h"
#import "NavigationHelperModel.h"
#import "HowToPlayViewController.h"
#import "GraphicsModel.h"

#define TH_IMG_X 215
#define TH_IMG_Y 60
#define TH_IMG_W 50
#define TH_IMG_H 50

@implementation MainMenuViewController

- (id)init {
	self = [super init];
	if (self) {
		array_levels = [[NSMutableArray alloc] init];
		table_levels = nil;
		
		[self generateLevelList];
	}	
	return self;
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,20,320,460)];
	contentView.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1];
	self.view = contentView;
	[contentView release];
	
	UIImageView *bck_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	bck_view.image = img_main_menu_bk;
	[contentView addSubview:bck_view];
	
	table_levels = [[UITableView alloc] initWithFrame:CGRectMake(10,174,263,263)];
	table_levels.delegate = self;
	table_levels.dataSource = self;
	table_levels.backgroundColor = [UIColor clearColor];
	table_levels.separatorStyle = UITableViewCellSeparatorStyleNone;
	table_levels.showsVerticalScrollIndicator = NO;
	[self.view addSubview:table_levels];
	
	tsv = [[TableScrollbarView alloc] initWithFrame:CGRectMake(277, 173, 38, 266)];
	tsv.scrollDelegate = self;
	[self.view addSubview:tsv];
	
	
	selectLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 144, 263, 20)];
	selectLevelLabel.backgroundColor = [UIColor clearColor];
	selectLevelLabel.text = @"Select A Level Below (1-87):";
	selectLevelLabel.textColor = [UIColor whiteColor];
	selectLevelLabel.font = Bsys18;
	selectLevelLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:selectLevelLabel];
	
	howToPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	howToPlayButton.frame = CGRectMake(25,90,170,35);
	howToPlayButton.backgroundColor = [UIColor clearColor];
	howToPlayButton.font = sys14;
	[howToPlayButton setBackgroundImage:[img_button_wait stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateNormal];
	[howToPlayButton setBackgroundImage:[img_button_wait_dn stretchableImageWithLeftCapWidth:10 topCapHeight:20] forState:UIControlStateHighlighted];
	[howToPlayButton setTitle:@"How To Play" forState:UIControlStateNormal];
	[howToPlayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[howToPlayButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:howToPlayButton];

	theseus_shadow = [[UIImageView alloc] initWithFrame:CGRectMake(TH_IMG_X, TH_IMG_Y, TH_IMG_W, TH_IMG_H)];
	theseus_shadow.image = img_thes_shadow;
	[self.view addSubview:theseus_shadow];

	theseus_img = [[UIImageView alloc] initWithFrame:CGRectMake(TH_IMG_X, TH_IMG_Y, TH_IMG_W, TH_IMG_H)];
	theseus_img.image = img_thes;
	[self.view addSubview:theseus_img];
	
	theseus_button = [UIButton buttonWithType:UIButtonTypeCustom];
	theseus_button.frame = CGRectMake(TH_IMG_X, TH_IMG_Y, TH_IMG_W, TH_IMG_H);
	theseus_button.backgroundColor = [UIColor clearColor];
	[theseus_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:theseus_button];
}


/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */

- (void)viewWillAppear:(BOOL)animated {
	/* Deselect the table */
	NSIndexPath *p = [table_levels indexPathForSelectedRow];
	if (p) {
		[table_levels deselectRowAtIndexPath:p animated:NO];
	}
}

- (void)buttonAction:(id)sender {
	if (sender == howToPlayButton) {
		HowToPlayViewController *htpvc = GetHowToPlayViewController();
		[[self navigationController] pushViewController:htpvc animated:YES];
	}
	if (sender == theseus_button) {
		CycleTheseusImg();
		theseus_img.image = img_thes;
	}
}

- (void) generateLevelList {
	for (int i = 0; i < NUM_LEVELS; i++) {
		LevelSelectTableCell *cell = [[LevelSelectTableCell alloc] initWithLevel:i];
		[array_levels addObject:cell];
		[cell release];
	}
}

- (void) redrawCell:(int)level {
	LevelSelectTableCell *cell = [array_levels objectAtIndex:level];
	[cell setNeedsDisplay];
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


/* ------ SCROLL VIEW -------- */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[tsv updateWithScroll:scrollView];
}

- (void)acceptTableScroll:(BOOL)page_move pageUp:(BOOL)pu position:(double)pos {
	if (page_move) {
		CGPoint new_pt = table_levels.contentOffset;
		if (pu) new_pt.y -= table_levels.frame.size.height;
		else new_pt.y += table_levels.frame.size.height;
		
		if (new_pt.y < 0) new_pt.y = 0;
		if (new_pt.y > (table_levels.contentSize.height - table_levels.frame.size.height))
			new_pt.y = (table_levels.contentSize.height - table_levels.frame.size.height);
		
		[table_levels setContentOffset:new_pt animated:YES];
	} else {
		[table_levels setContentOffset:CGPointMake(0, (table_levels.contentSize.height - table_levels.frame.size.height) * pos)];
	}
	
	[tsv updateWithScroll:(UIScrollView*)table_levels];
}

- (void) scrollToLevel:(int)level {
	//if (!table_levels) return;
	//[table_levels scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndex:level]  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

/* -------------------------- TABLE DELEGATE METHODS ----------------------- */

// decide what kind of accesory view (to the far right) we will use
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDisclosureIndicator;
}

// Push the details view controller when a contract is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger row = [indexPath row];
	DungeonViewController *dvc = GetDungeonViewController();
	
	[[self navigationController] pushViewController:dvc animated:YES];
	[dvc initializeForLevel:row];
}

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [array_levels count];
}

// utility routine leveraged by 'cellForRowAtIndexPath' to determine which UITableViewCell to be used on a given row
//
- (UITableViewCell *)obtainTableCellForRow:(NSInteger)row
{
	UITableViewCell *cell = [array_levels objectAtIndex:row];
	
	return cell;	
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	UITableViewCell *sourceCell = [self obtainTableCellForRow:row];
    return sourceCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kRecentGameCellHeight;
}


@end
