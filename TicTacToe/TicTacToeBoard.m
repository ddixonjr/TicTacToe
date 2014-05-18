//
//  TicTacToeBoard.m
//  TicTacToe
//
//  Created by Dennis Dixon on 5/18/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "TicTacToeBoard.h"


@interface TicTacToeBoard ()
@property (strong,nonatomic) NSMutableArray *ticTacToeBoardArray;
@end

@implementation TicTacToeBoard

#pragma mark - Public Methods

-(BOOL)isValidMoveToSpace:(NSInteger)space
{
   if ([[self.ticTacToeBoardArray objectAtIndex:space] isEqualToString:kEmptyNSString])
       return YES;

    return NO;
}

-(void)processValidatedMove:(NSString *)player toSpace:(NSInteger)space
{
    [self.ticTacToeBoardArray setObject:player atIndexedSubscript:space];
}


-(void)initializeNewBoard
{
    self.ticTacToeBoardArray = nil;  // uses the default setter to release the array

    for (NSInteger element = 0; element<kTicTacToeSpaces;element++)  // populate the new array with empty NSString objects
    {
        [self.ticTacToeBoardArray addObject:kEmptyNSString];   // uses the getter to alloc/init a new array the first iteration
    }

}

-(BOOL)isBoardFilled
{
    NSLog(@"in TicTacToeBoard - isBoardFilled");
    NSInteger spacesFilled = 0;
    for (NSString *ticTacToeSpaceString in self.ticTacToeBoardArray)
    {
        if ([ticTacToeSpaceString isEqualToString:kPlayerOneSymbol] || [ticTacToeSpaceString isEqualToString:kPlayerTwoSymbol])
            spacesFilled++;
    }

    return ((spacesFilled >= 9) ? YES : NO);
}

-(NSArray *)getTicTacToeBoardArray
{
    return (NSArray *) self.ticTacToeBoardArray;
}

#pragma mark - Helper Methods

-(NSString *) whoWon
{
    NSLog(@"in TicTacToeBoard whoWon - ticTacToeBoard.count = %d",  self.ticTacToeBoardArray.count);
    NSString *candidateWinner = [self testForWinner:self.ticTacToeBoardArray[0] second:self.ticTacToeBoardArray[1] third:self.ticTacToeBoardArray[2]];

    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:self.ticTacToeBoardArray[3] second:self.ticTacToeBoardArray[4] third:self.ticTacToeBoardArray[5]];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:self.ticTacToeBoardArray[6] second:self.ticTacToeBoardArray[7] third:self.ticTacToeBoardArray[8]];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:self.ticTacToeBoardArray[0] second:self.ticTacToeBoardArray[3] third:self.ticTacToeBoardArray[6]];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:self.ticTacToeBoardArray[1] second:self.ticTacToeBoardArray[4] third:self.ticTacToeBoardArray[7]];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:self.ticTacToeBoardArray[2] second:self.ticTacToeBoardArray[5] third:self.ticTacToeBoardArray[8]];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:self.ticTacToeBoardArray[0] second:self.ticTacToeBoardArray[4] third:self.ticTacToeBoardArray[8]];
    if (candidateWinner == nil)
        candidateWinner = [self testForWinner:self.ticTacToeBoardArray[2] second:self.ticTacToeBoardArray[4] third:self.ticTacToeBoardArray[6]];

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


#pragma mark - Accessor Methods

-(NSMutableArray *)ticTacToeBoardArray
{
    if (_ticTacToeBoardArray == nil)
    {
        _ticTacToeBoardArray = [[NSMutableArray alloc] init];
    }

    return _ticTacToeBoardArray;
}





@end