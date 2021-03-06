//
//  GameViewController.m
//  Scribe
//
//  Created by Stephen Searles on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "SCGameBoardView.h"
#import "SCMiniGridView.h"
#import "SCMiniGrid.h"
#import "SCCellView.h"
#import "SCScribeBoard.h"

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveSelected:) name:SCCellSelectedNotification object:nil];
    scribeBoard = [[SCScribeBoard alloc] init];
    SCGameBoardView * gameBoard = [[SCGameBoardView alloc] initWithFrame:CGRectMake(20, 116, 280, 280) gameBoard:scribeBoard];
    [self.view addSubview:gameBoard];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:gameBoard action:@selector(resetBoard)]];
    [super viewDidLoad];
}

- (void)moveSelected:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)moveUnselected:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (IBAction)makeMove:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SCCellPlayedNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:scribeBoard.currentPlayer],@"Player", nil]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
