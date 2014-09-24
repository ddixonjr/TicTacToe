//
//  TicTacToeBoardViewController.m
//  TicTacToe
//
//    -MVP created by Robert Figueras and Dennis Dixon on 5/15/14.
//    -All additional functionality and model classes developed by Dennis Dixon
//
//  Copyright (c) 2014 Appivot LLC All rights reserved.
//

#import "TicTacToeBoardViewController.h"
#import "TicTacToeBoard.h"
#import "VirtualPerson.h"

@interface TicTacToeBoardViewController () <UIAlertViewDelegate,VirtualPersonTicTacToeOpponent>

// Game Grid Properties
@property (strong, nonatomic) IBOutlet UILabel *myLabelOne;
@property (strong, nonatomic) IBOutlet UILabel *myLabelTwo;
@property (strong, nonatomic) IBOutlet UILabel *myLabelThree;
@property (strong, nonatomic) IBOutlet UILabel *myLabelFour;
@property (strong, nonatomic) IBOutlet UILabel *myLabelFive;
@property (strong, nonatomic) IBOutlet UILabel *myLabelSix;
@property (strong, nonatomic) IBOutlet UILabel *myLabelSeven;
@property (strong, nonatomic) IBOutlet UILabel *myLabelEight;
@property (strong, nonatomic) IBOutlet UILabel *myLabelNine;
@property (strong, nonatomic) IBOutlet UILabel *whichPlayerLabel;
@property (strong, nonatomic) NSArray *ticTacToeGridArray;

// Player Tracking Properties
@property (nonatomic) BOOL isItPlayerOne;
@property (nonatomic) NSInteger numberOfTurnsTaken;

@property (nonatomic) CGPoint origPlayerLabelPoint;
@property (nonatomic) CGAffineTransform origPlayerLabelTransform;
//@property (strong,nonatomic) IBOutlet UILabel *loseTurnLabel;

@property (nonatomic) BOOL isDraggingToSpace;
@property (strong,nonatomic) NSTimer *turnTimer;

// Properties added as a part of RefactorToMVC_Attempt01
@property (strong,nonatomic) TicTacToeBoard *ticTacToeBoard;
@property (strong,nonatomic) NSString *currentPlayerLetter;


// Properties added as a part of the VirtualPerson implementation

@property (weak, nonatomic) IBOutlet UISegmentedControl *opponentTypeSegmentedControl;
@property (strong,nonatomic) VirtualPerson *virtualOpponent;
@property (nonatomic,getter=isGameOn,setter=gameOn:) BOOL gameOn;

@end



@implementation TicTacToeBoardViewController


#pragma mark - UIViewController Life Cycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ticTacToeBoard = [[TicTacToeBoard alloc] init];

    self.ticTacToeGridArray = [NSArray arrayWithObjects:self.myLabelOne,
                                   self.myLabelTwo,
                                   self.myLabelThree,
                                   self.myLabelFour,
                                   self.myLabelFive,
                                   self.myLabelSix,
                                   self.myLabelSeven,
                                   self.myLabelEight,
                                   self.myLabelNine,
                                   nil];
    [self resetBoard];
    self.origPlayerLabelPoint = self.whichPlayerLabel.center;
    self.opponentTypeSegmentedControl.selectedSegmentIndex = kOpponentTypeHuman;

}

            


#pragma mark - Gesture Recognizer Action Methods

-(IBAction)onLabelTapped:(UITapGestureRecognizer*) tapGestureRecognizer {


    CGPoint tappedPoint = [tapGestureRecognizer locationInView:self.view];
    UILabel *selectedLabel = [self findLabelUsingPoint:tappedPoint];

    //  Debug statements
    if (selectedLabel) NSLog(@"in onLabelTapped - \nselectedLabel.tag = %ld", (long)selectedLabel.tag);
    else NSLog(@"in onLabelTapped - \nselectedLabel is nil");
//    NSLog(@"tappedPoint = (%0.2f,%0.2f", tappedPoint.x,tappedPoint.y);


    BOOL isValidMove = ([self.ticTacToeBoard isValidMoveToSpace:selectedLabel.tag]
                        && selectedLabel != nil
                        && [selectedLabel.text isEqualToString:kEmptyNSString]);

    if (isValidMove) {
        [self processValidatedMove:selectedLabel];
    }

}


-(IBAction)onDragOfPlayerSymbol:(UIPanGestureRecognizer *)panGestureRecognizer
{
    self.isDraggingToSpace = YES;
    CGPoint curPanPoint = [panGestureRecognizer locationInView:self.view];

    // if user touched the actual player symbol label start moving in line with the center
    if (CGRectContainsPoint(self.whichPlayerLabel.frame,curPanPoint))
    {
        self.whichPlayerLabel.center = curPanPoint;
    }

    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"Pan stopped");
        self.isDraggingToSpace = NO;
        UILabel *selectedLabel = [self findLabelUsingPoint:curPanPoint];
        BOOL isValidMove = ([self.ticTacToeBoard isValidMoveToSpace:selectedLabel.tag]
                            && selectedLabel != nil
                            && [selectedLabel.text isEqualToString:kEmptyNSString]);

        if (isValidMove)
        {
            [self processValidatedMove:selectedLabel];
            self.whichPlayerLabel.center = self.origPlayerLabelPoint;
        }
        else {
            [UIView animateWithDuration:0.8 animations:^{
            self.whichPlayerLabel.center = self.origPlayerLabelPoint;
            }];
        }
    }

}


#pragma mark - IBAction Methods


-(IBAction)onOpponentTypeSegmentedControlChanged
{
    if ([self isOpponentTypeComputer])
    {
        self.virtualOpponent = [[VirtualPerson alloc] initWithTicTacToeBoard:self.ticTacToeBoard];
        self.virtualOpponent.delegate = self;
    }
}


#pragma mark - virtual person delegate

-(void)virtualPersonTicTacToeOpponent:(VirtualPerson *)vitualPerson selectSpace:(NSInteger)space
{
    NSLog(@"in virtualPersonTicTacToeOpponent - selectedSpace = %ld",(long)space);
    UILabel *virtualOpponentSelectedLabel = nil;

    for (UILabel *curLabel in self.ticTacToeGridArray)
    {
        if (curLabel.tag == space)
        {
            virtualOpponentSelectedLabel = curLabel;
            break;
        }
    }
    [self processValidatedMove:virtualOpponentSelectedLabel];
}


#pragma mark - UIAlertView Delegate method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self resetBoard];
}


#pragma mark - Helper Methods

- (void)processValidatedMove:(UILabel *)selectedLabel {
    [self stopTurnTimer];  // Need to move this to the tap and drag methods to keep the timer in this VC
    [self.opponentTypeSegmentedControl setEnabled:NO];

    [self.ticTacToeBoard processValidatedMove:self.currentPlayerLetter toSpace:selectedLabel.tag];
    [self refreshDisplayedTicTacToeBoard];

    NSString *winnerString = [self.ticTacToeBoard whoWon];
    NSLog(@"winnerString: %@",winnerString);

    if (winnerString != nil) {
        NSString *titleString = [NSString stringWithFormat:@"%@ Won",winnerString];
        [self showRestartGameAlertWithTitle:titleString andMessage:@"Great Job!"];
    }
    else {
        self.numberOfTurnsTaken++;
        if ([self.ticTacToeBoard isBoardFilled]) {
            [self showRestartGameAlertWithTitle:@"Game Over" andMessage:@"No winner this time."];
        }
        else {
            [self togglePlayerTurn];
            [self startTurnTimer];
        }
    }

}


-(void)startTurnTimer
{
    self.turnTimer = [NSTimer scheduledTimerWithTimeInterval:kMaxTurnTime target:self selector:@selector(turnExpired) userInfo:nil repeats:NO];
}


-(void)stopTurnTimer
{
    [self.turnTimer invalidate];
    self.turnTimer = nil;        }


-(void)turnExpired
{
    if (!self.isDraggingToSpace) {
        NSLog(@"in turnExpired -- self.turnTimer = %@",self.turnTimer);

        NSString *playerString = self.isItPlayerOne ? kPlayerTwoSymbol : kPlayerOneSymbol;
        NSString *forfeitMessageString = [NSString stringWithFormat:@"%@ Won by Forfeit",playerString];
        [self showRestartGameAlertWithTitle:@"Game Over" andMessage:forfeitMessageString];
    }
}


-(void)showRestartGameAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Try Again!" otherButtonTitles:nil];
    [alert show];
}


-(UILabel *)findLabelUsingPoint:(CGPoint) point{

    for (UILabel *currentLabel in self.ticTacToeGridArray) {
        if (CGRectContainsPoint(currentLabel.frame, point)){
            return currentLabel;
        }
    }
    return nil;
}

-(void)resetBoard {
    [self.opponentTypeSegmentedControl setEnabled:YES];
    self.isItPlayerOne = YES;

    self.whichPlayerLabel.text = self.currentPlayerLetter = kPlayerOneSymbol;  // RefactorToMVC_Attempt01
    self.whichPlayerLabel.textColor = (self.isItPlayerOne) ? [UIColor blueColor] : [UIColor redColor];

    [self.ticTacToeBoard initializeNewBoard];
    [self refreshDisplayedTicTacToeBoard];

    if ([self isOpponentTypeComputer])
    {
        self.virtualOpponent = nil;
        self.virtualOpponent = [[VirtualPerson alloc] initWithTicTacToeBoard:self.ticTacToeBoard];
        self.virtualOpponent.delegate = self;

    }
}


-(void)refreshDisplayedTicTacToeBoard
{
    NSArray *ticTacToeBoardObjectArray = [self.ticTacToeBoard getTicTacToeBoardArray];

    for (UILabel *curLabel in self.ticTacToeGridArray)
    {
        curLabel.text = [ticTacToeBoardObjectArray objectAtIndex:curLabel.tag];
        if ([curLabel.text isEqualToString:kPlayerOneSymbol])
        {
            curLabel.textColor = [UIColor blueColor];
        }
        else if ([curLabel.text isEqualToString:kPlayerTwoSymbol])
        {
            curLabel.textColor = [UIColor redColor];
        }
    }
}

-(void)togglePlayerTurn
{
    self.isItPlayerOne = !self.isItPlayerOne;
    self.currentPlayerLetter = self.isItPlayerOne ? kPlayerOneSymbol : kPlayerTwoSymbol;

    self.whichPlayerLabel.textColor = (self.isItPlayerOne) ? [UIColor blueColor] : [UIColor redColor];
    self.whichPlayerLabel.text = self.currentPlayerLetter;

    if ([self isOpponentTypeComputer] && !self.isItPlayerOne)
    {
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(passTurnToVirtualOpponent) userInfo:nil repeats:NO];
    }
}


-(void)passTurnToVirtualOpponent
{
    [self.virtualOpponent takeTurn];
}

-(void)setOpponentType:(NSInteger)opponentType
{
    self.opponentTypeSegmentedControl.selectedSegmentIndex = opponentType;
}

-(BOOL)isOpponentTypeComputer
{
    return ((self.opponentTypeSegmentedControl.selectedSegmentIndex == kOpponentTypeComputer) ? YES : NO);
}

- (NSString *) whoWon
{
    return [self.ticTacToeBoard whoWon];
}


@end
