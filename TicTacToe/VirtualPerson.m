//
//  VirtualPerson.m
//  TicTacToe
//
//  Created by Dennis Dixon on 5/18/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "VirtualPerson.h"

@interface VirtualPerson ()
@property (nonatomic) NSInteger myTurnNumber;

@end


@implementation VirtualPerson

-(id)init
{
    self = [super init];
    if (self)
    {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeTurn) name:@"TTTVirtualPersonTurnNotification" object:nil];
        [self rebootVirtualPerson];
    }
    return self;
}

-(id)initWithTicTacToeBoard:(TicTacToeBoard *)ticTacToeBoard
{
    self = [self init];
    self.ticTacToeBoard = ticTacToeBoard;
    return self;
}


-(void)takeTurn
{
    NSLog(@"I am virtual Dennis and it's my turn.");
    NSLog(@"The board looks like this: %@",[self.ticTacToeBoard getTicTacToeBoardArray]);

    if (self.delegate  && [self.delegate respondsToSelector:@selector(virtualPersonTicTacToeOpponent:selectSpace:)] )
    {
        [self.delegate virtualPersonTicTacToeOpponent:self selectSpace:self.myTurnNumber++];
    }

}

-(void)rebootVirtualPerson
{
    self.myTurnNumber = 0;
}



@end
