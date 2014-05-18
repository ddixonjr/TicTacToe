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
//  5/18/14: (Dennis) branchFrom:RefactorToMVC toBranch:RefactorToMVC_Attempt01
//              -This is the first crack at refactoring this puppy into a basic but true MVC patterned app
//               as described in the previous comment.
//
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "TicTacToeBoardViewController.h"
#import "TicTacToeBoard.h"




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

// Properties added as a part of RefactorToMVC_Attempt01
@property (strong,nonatomic) TicTacToeBoard *ticTacToeBoard;
@property (strong,nonatomic) NSString *currentPlayerLetter;

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
    //   to do that, I'll have to rely on the TTTBoard object to tell me YES or NO based on it's status AND derive
    //   the displayed label grid from a 'mapping' of the board pulled from the TTTBoard object
    // From code:
    //   BOOL isValidMove = ((selectedLabel != nil) && (selectedLabel.text.length == 0));
    // To code:

    BOOL isValidMove = [self.ticTacToeBoard isValidMoveToSpace:selectedLabel.tag]; // RefactorToMVC_Attempt01

    if (isValidMove) {
        // RefactorToMVC Candidate:  I think I should move this call to a method the to be TicTacToeBoard
        //   class --  I rethought this and will call the board object's processValidateMove
        //   within this VC's process validated method
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
//        BOOL isValidMove = ((selectedLabel != nil) && (selectedLabel.text.length == 0));
        BOOL isValidMove = [self.ticTacToeBoard isValidMoveToSpace:selectedLabel.tag];

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

    // RefactorToMVC_Attempt01
    [self.ticTacToeBoard processValidatedMove:self.currentPlayerLetter toSpace:selectedLabel.tag];

//    [self populateLabelWithCorrectPlayer:selectedLabel];    // Need to move this to be the VC's way to present the moves
                                                            // on the screen based on asking the TicTacToeBoard object
                                                            // for a "boardMap" which (at this point) may just be
                                                            // a simple 9 element NSArray like the ticTacToeGridArray in this VC
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
//            [self populateLabelWithCorrectPlayer:self.whichPlayerLabel];  // I now set the whichPlayerLabel in togglePlayerTurn
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


-(UILabel *)findLabelUsingPoint:(CGPoint) point{
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
    self.whichPlayerLabel.text = self.currentPlayerLetter = kPlayerOneSymbol;  // RefactorToMVC_Attempt01
    self.whichPlayerLabel.textColor = (self.isItPlayerOne) ? [UIColor blueColor] : [UIColor redColor];

//    [self populateLabelWithCorrectPlayer:self.whichPlayerLabel];
    self.numberOfTurnsTaken = 0;


    [self.ticTacToeBoard initializeNewBoard];
    [self refreshDisplayedTicTacToeBoard];

//    for (UILabel *label in self.ticTacToeGridArray) {
//        label.text = kEmptyNSString;
//    }
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
        
//        NSLog(@"in refreshDisplayedTicTacToeBoard - curLabel.text contains %@", curLabel.text);
//        NSLog(@"in refreshDisplayedTicTacToeBoard - self.myLabelFive.text contains %@", self.myLabelFive.text);

    }
//    NSLog(@"in refreshDisplayedTicTacToeBoard - ticTacToeBoardObjectArray contains %@", ticTacToeBoardObjectArray);
}


//  Removed in RefactorToMVC_Attempt01 because the refreshDisplayedTicTacToeBoard method
//    now syncs the display with the ticTacToeBoard object
//-(void)populateLabelWithCorrectPlayer:(UILabel *)label
//{
//    label.textColor = (self.isItPlayerOne) ? [UIColor blueColor] : [UIColor redColor];
//    label.text = self.currentPlayerLetter;
//    NSLog(@"in populateLabelWithCorrectPlayer - label.text = %@",label.text);
//}
//

-(void)togglePlayerTurn
{
// RefactorToMVC Candidate:  This is where I think I have to send a notification to the VirtualPerson object when it's it's turn
    self.isItPlayerOne = !self.isItPlayerOne;
    self.currentPlayerLetter = self.isItPlayerOne ? kPlayerOneSymbol : kPlayerTwoSymbol;
    self.whichPlayerLabel.textColor = (self.isItPlayerOne) ? [UIColor blueColor] : [UIColor redColor];
    self.whichPlayerLabel.text = self.currentPlayerLetter;

}


-(TicTacToeBoard *)ticTacToeBoard
{
    if (_ticTacToeBoard == nil)
    {
        _ticTacToeBoard = [[TicTacToeBoard alloc] init];
    }
    return _ticTacToeBoard;
}


- (NSString *) whoWon
{
    return [self.ticTacToeBoard whoWon];
}

@end
