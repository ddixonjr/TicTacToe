//
//  ViewController.m
//  TicTacToe
//
//  Created by Robert Figueras on 5/15/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "GameBoardViewController.h"

@interface GameBoardViewController () <UIAlertViewDelegate>

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

@end

@implementation GameBoardViewController

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
    self.origPlayerLabelTransform = self.whichPlayerLabel.transform;
//    self.loseTurnLabel.text = @"Hey, I'm here!";
}

            


#pragma mark - Gesture Recognizer Action Methods



-(IBAction)onLabelTapped:(UITapGestureRecognizer*) tapGestureRecognizer {

    CGPoint tappedPoint = [tapGestureRecognizer locationInView:self.view];

    UILabel *selectLabel = [self findLabelUsingPoint:tappedPoint];

    if (selectLabel.text.length == 0) {
        [self processMove:selectLabel];

    }

}


-(IBAction)onDragOfPlayerSymbol:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint curPanPoint = [panGestureRecognizer locationInView:self.view];
//    curPanPoint.x += self.whichPlayerLabel.center.x;
//    curPanPoint.y += self.whichPlayerLabel.center.y;
//

    NSLog(@"curPanPoint (%0.2f,%0.2f)",curPanPoint.x,curPanPoint.y);

    // if user touched the actual player symbol label start moving in line with the center
    if (CGRectContainsPoint(self.whichPlayerLabel.frame,curPanPoint))
    {
//        self.whichPlayerLabel.transform = CGAffineTransformMakeTranslation(curPanPoint.x,curPanPoint.y);
        self.whichPlayerLabel.center = curPanPoint;
        NSLog(@"Touching whichPlayerLabel (center = (%0.2f,%0.2f))",self.whichPlayerLabel.center.x,self.whichPlayerLabel.center.y);
    }

    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        UILabel *selectedLabel = [self findLabelUsingPoint:curPanPoint];
        if (selectedLabel != nil)
        {
            [self processMove:selectedLabel];
            self.whichPlayerLabel.center = self.origPlayerLabelPoint;
        }
        else {
            [UIView animateWithDuration:0.8 animations:^{
            self.whichPlayerLabel.center = self.origPlayerLabelPoint;
        }];
        }
    }

}


#pragma mark - UIAlertView Delegate method


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self resetBoard];
}

#pragma mark - Helper Methods

- (void)processMove:(UILabel *)selectedLabel {
    [self populateLabelWithCorrectPlayer:selectedLabel];

    self.numberOfTurnsTaken ++;

    if ([self isTheBoardFilled]) {

        self.whichPlayerLabel.text = @"GAME OVER";
    }

    else {
        NSString *winnerString = [self whoWon];

        NSLog(@"winnerString: %@",winnerString);
        if (winnerString != nil) {
            NSString *messageString = [NSString stringWithFormat:@"%@ Won",winnerString];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageString
                                                            message:@"Great Job!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Restart Game"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            [self setPlayerLabel];
            NSLog(@"Just prior to NSTimer");
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(turnExpired) userInfo:nil repeats:NO];
        }
    }
}

-(void)turnExpired
{
    NSLog(@"in turnExpired");
//    self.loseTurnLabel.text = @"Turn Over";
    NSLog(@"loseTurnLabel.text = %@",self.loseTurnLabel.text);
//    [NSThread sleepForTimeInterval:1.0];
//    self.loseTurnLabel.text = @"";
    self.isItPlayerOne = !self.isItPlayerOne;
    [self setPlayerLabel];
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
        label.text = @"";
    }
}


- (void)populateLabelWithCorrectPlayer: (UILabel *)selectedLabel{

    if (self.isItPlayerOne) {
        selectedLabel.text = @"X";
        selectedLabel.textColor = [UIColor blueColor];
    }
    else {
        selectedLabel.text = @"O";
        selectedLabel.textColor = [UIColor redColor];
    }
    self.isItPlayerOne = !self.isItPlayerOne;

}

- (void)setPlayerLabel{

    if (self.isItPlayerOne) {
        self.whichPlayerLabel.text = @"X";
        self.whichPlayerLabel.textColor = [UIColor blueColor];
    }
    else {
        self.whichPlayerLabel.text = @"O";
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
//    if ([self.my])

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
    if ([first isEqualToString:@"X"] && [second isEqualToString:@"X"] && [third isEqualToString:@"X"]) {
        NSLog(@"X IS THE WINNER");
        return @"X";
    }
    else if ([first isEqualToString:@"O"] && [second isEqualToString:@"O"] && [third isEqualToString:@"O"]) {
        NSLog(@"O IS THE WINNER");
        return @"O";
    }
    return nil;
}

@end
