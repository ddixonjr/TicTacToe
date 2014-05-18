//
//  TicTacToeBoardViewController.m
//  TicTacToe
//
//  5/16/14: (Dennis) branchIn:master
//              -Originally created by Robert Figueras and Dennis Dixon on 5/15/14.
//
//  5/17/14: (Dennis) branchFrom:master toBranch:StretchOneDennis
//              -Dennis' implementation of a drag-to-space feature
//
//  5/17/14: (Dennis) branchFrom:StretchOneDennis toBranch:StretchTwoDennis
//              -Dennis' implementation of the following:
//                  -A turn timer feature
//                  -Refactoring that renames and further segments some
//                   of the original method functionality in to more smaller methods
//
//  5/18/14: (Dennis) branchFrom:master toBranch:FixBoardFilled
//              -This version contains a fix from Dennis breaking the board filled functionality
//
//  5/18/14: (Dennis) branchFrom:master toBranch:RefactorToMVC
//              -This is the start of possibly many attempts to refactor this app in alignment with
//               the MVC pattern.  No code changes exist in this branch yet--only comments on some thoughts I have.
//               I will create "attempt" branches off of this one to allow me to explore until I can merge a working
//               version into this branch for merge into the master.
//                  -The overall purpose is to decouple the board from the view controller into its own
//                   object so that later a VirtualPerson object can also 'look' at the board and then
//                   make method calls to an instance of this view controller to make moves...
//                   at least that's the plan as of now.  :)
//
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "TicTacToeBoardViewController.h"
#define kMaxTurnTime 8.0
#define kPlayerOneSymbol @"X"
#define kPlayerTwoSymbol @"O"
#define kEmptyNSString @""


@interface TicTacToeBoardViewController () <UIAlertViewDelegate>

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
@property (strong,nonatomic) IBOutlet UILabel *loseTurnLabel;

@property (nonatomic) BOOL isDraggingToSpace;
@property (strong,nonatomic) NSTimer *turnTimer;

@end

@implementation TicTacToeBoardViewController


#pragma mark - UIViewController Life Cycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

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
}

            


#pragma mark - Gesture Recognizer Action Methods

-(IBAction)onLabelTapped:(UITapGestureRecognizer*) tapGestureRecognizer {

    NSLog(@"in onLabelTapped");

    CGPoint tappedPoint = [tapGestureRecognizer locationInView:self.view];
    UILabel *selectedLabel = [self findLabelUsingPoint:tappedPoint];

//    This was just a test to see what an attempt to call the length property getter would evaluate to
//    if the label if the actual object were nil...it evaluated to 0
//    This is really interesting because if you're testing this 'return' for zero later as we are below,
//    you're testing an invalidly derived result! ...good stuff to know!
//    
//    if (selectLabel==nil) NSLog(@"length of nil text label = %d",selectLabel.text.length);


    // RefactorToMVC Candidate:  I think I should move this test to a method the to be TicTacToeBoard class
    BOOL isValidMove = ((selectedLabel != nil) && (selectedLabel.text.length == 0));

    if (isValidMove) {
        // RefactorToMVC Candidate:  I think I should move this call to a method the to be TicTacToeBoard class
        [self processValidatedMove:selectedLabel];
    }

}


-(IBAction)onDragOfPlayerSymbol:(UIPanGestureRecognizer *)panGestureRecognizer
{
    self.isDraggingToSpace = YES;
    CGPoint curPanPoint = [panGestureRecognizer locationInView:self.view];
//    curPanPoint.x += self.whichPlayerLabel.center.x;
//    curPanPoint.y += self.whichPlayerLabel.center.y;
//

//    NSLog(@"curPanPoint (%0.2f,%0.2f)",curPanPoint.x,curPanPoint.y);

    // if user touched the actual player symbol label start moving in line with the center
    if (CGRectContainsPoint(self.whichPlayerLabel.frame,curPanPoint))
    {
//        self.whichPlayerLabel.transform = CGAffineTransformMakeTranslation(curPanPoint.x,curPanPoint.y);
        self.whichPlayerLabel.center = curPanPoint;
//        NSLog(@"Touching whichPlayerLabel (center = (%0.2f,%0.2f))",self.whichPlayerLabel.center.x,self.whichPlayerLabel.center.y);
    }

    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"Pan stopped");
//        [self stopTurnTimer];  // Contemplating doing this in processMove only to perform in only one place
        self.isDraggingToSpace = NO;
        UILabel *selectedLabel = [self findLabelUsingPoint:curPanPoint];
        BOOL isValidMove = ((selectedLabel != nil) && (selectedLabel.text.length == 0));

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
//      [self startTurnTimer];  // Contemplating doing this in processMove only to perform in only one place
    }

}


#pragma mark - UIAlertView Delegate method


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self resetBoard];
}

#pragma mark - Helper Methods

- (void)processValidatedMove:(UILabel *)selectedLabel {

    [self stopTurnTimer];  // Need to move this to the tap and drag methods to keep the timer in this VC

    // Fundamental questions: should the board or the view controller determine who won???
    //  -should a model object like TicTacToeBoard be able to determine if a winner exists?
    //  -should it that function be separated out into a TicTacToeBoardManager object that
    //     handles that function OR should this view controller just be able to ask the
    //     TicTacToeBoard model object if a winner exists?

    [self populateLabelWithCorrectPlayer:selectedLabel];    // Need to move this to be the VC's way to present the moves
                                                            // on the screen based on asking the TicTacToeBoard object
                                                            // for a "boardMap" which (at this point) may just be
                                                            // a simple 9 element NSArray like the ticTacToeGridArray in this VC

    NSString *winnerString = [self whoWon];
    NSLog(@"winnerString: %@",winnerString);

    if (winnerString != nil) {
        NSString *titleString = [NSString stringWithFormat:@"%@ Won",winnerString];
        [self showRestartGameAlertWithTitle:titleString andMessage:@"Great Job!"];
    }
    else {
        self.numberOfTurnsTaken++;
        if ([self isTheBoardFilled]) {
            [self showRestartGameAlertWithTitle:@"Game Over" andMessage:@"No winner this time."];
        }
        else {
            [self togglePlayerTurn];
            [self setPlayerLabel];
            [self startTurnTimer];
        }
    }
}

-(void)startTurnTimer
{
    NSLog(@"in startTurnTimer");
    self.turnTimer = [NSTimer scheduledTimerWithTimeInterval:kMaxTurnTime target:self selector:@selector(turnExpired) userInfo:nil repeats:NO];
}

-(void)stopTurnTimer
{
    NSLog(@"in stopTurnTimer");
    [self.turnTimer invalidate];    // Remove the strong reference in NSRunLoop to the NSTimer object
    self.turnTimer = nil;           // Remove my strong reference to it as well!  While I could probably make my reference weak,
                                    //   I prefer this method because I can release it when *I* choose to...barring iOS somehow
                                    //   barring iOS somehow ignoring me on this type of object.  :)


}

-(void)turnExpired
{

    if (!self.isDraggingToSpace) {
        NSLog(@"in turnExpired -- self.turnTimer = %@",self.turnTimer);
//        I decided to ditch the idea of just passing the turn to the other player
//        since that would probably mean certain victory for that other player
//        self.loseTurnLabel.text = @"Turn Over";
//        NSLog(@"loseTurnLabel.text = %@",self.loseTurnLabel.text);
//        [NSThread sleepForTimeInterval:1.0];
//        self.loseTurnLabel.text = kEmptyNSString;
//        self.isItPlayerOne = !self.isItPlayerOne;
//        [self setPlayerLabel];

//        Instead, I'll just flag the expired turn player with a forfeit
        NSString *playerString = self.isItPlayerOne ? kPlayerTwoSymbol : kPlayerOneSymbol; // Which ever player is current just forfeited so the other player won
        NSString *forfeitMessageString = [NSString stringWithFormat:@"%@ Won by Forfeit",playerString];
        [self showRestartGameAlertWithTitle:@"Game Over" andMessage:forfeitMessageString];
    }
}

-(void)showRestartGameAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Try Again!" otherButtonTitles:nil];
    [alert show];
}

- (UILabel *)findLabelUsingPoint:(CGPoint) point{
    //    NSLog(@"here is your point %f %f",point.x,point.y);

    for (UILabel *currentLabel in self.ticTacToeGridArray) {

        if (CGRectContainsPoint(currentLabel.frame, point)){
            NSLog(@"you touched label %d", currentLabel.tag);
            return currentLabel;
        }
    }
    return nil;
}


-(void)resetBoard {

    self.isItPlayerOne = YES;
    [self setPlayerLabel];
    self.numberOfTurnsTaken = 0;

    for (UILabel *label in self.ticTacToeGridArray) {
        label.text = kEmptyNSString;
    }
}


- (void)populateLabelWithCorrectPlayer: (UILabel *)selectedLabel{

    if (self.isItPlayerOne) {
        selectedLabel.text = kPlayerOneSymbol;
        selectedLabel.textColor = [UIColor blueColor];
    }
    else {
        selectedLabel.text = kPlayerTwoSymbol;
        selectedLabel.textColor = [UIColor redColor];
    }


}

-(void)togglePlayerTurn
{

// RefactorToMVC Candidate:  This is where I think I have to send a notification to the VirtualPerson object when it's it's turn
    self.isItPlayerOne = !self.isItPlayerOne;
}

- (void)setPlayerLabel{

    if (self.isItPlayerOne) {
        self.whichPlayerLabel.text = kPlayerOneSymbol;
        self.whichPlayerLabel.textColor = [UIColor blueColor];
    }
    else {
        self.whichPlayerLabel.text = kPlayerTwoSymbol;
        self.whichPlayerLabel.textColor = [UIColor redColor];
    }

}

// helper method to determine if board is filled

-(BOOL) isTheBoardFilled {

    if (self.numberOfTurnsTaken > 8) {

        return YES;
    }
    return NO;
}


// helper method to determine winner

- (NSString *) whoWon
{

    NSString *first = [NSString stringWithFormat:@"%@",self.myLabelOne.text];
    NSString *second = [NSString stringWithFormat:@"%@",self.myLabelTwo.text];
    NSString *third = [NSString stringWithFormat:@"%@",self.myLabelThree.text];
    NSString *forth = [NSString stringWithFormat:@"%@",self.myLabelFour.text];
    NSString *fifth = [NSString stringWithFormat:@"%@",self.myLabelFive.text];
    NSString *sixth = [NSString stringWithFormat:@"%@",self.myLabelSix.text];
    NSString *seventh = [NSString stringWithFormat:@"%@",self.myLabelSeven.text];
    NSString *eighth = [NSString stringWithFormat:@"%@",self.myLabelEight.text];
    NSString *ninth = [NSString stringWithFormat:@"%@",self.myLabelNine.text];

    NSString *candidateWinner = [self testForWinner:first second:second third:third];

    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:forth second:fifth third:sixth];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:seventh second:eighth third:ninth];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:first second:forth third:seventh];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:second second:fifth third:eighth];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:third second:sixth third:ninth];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:first second:fifth third:ninth];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:third second:fifth third:seventh];


    return candidateWinner;
}

- (NSString *)testForWinner:(NSString *)first second:(NSString *)second third:(NSString *)third
{
    if ([first isEqualToString:kPlayerOneSymbol] && [second isEqualToString:kPlayerOneSymbol] && [third isEqualToString:kPlayerOneSymbol]) {
        NSLog(@"X IS THE WINNER");
        return kPlayerOneSymbol;
    }
    else if ([first isEqualToString:kPlayerTwoSymbol] && [second isEqualToString:kPlayerTwoSymbol] && [third isEqualToString:kPlayerTwoSymbol]) {
        NSLog(@"O IS THE WINNER");
        return kPlayerTwoSymbol;
    }
    return nil;
}

@end
