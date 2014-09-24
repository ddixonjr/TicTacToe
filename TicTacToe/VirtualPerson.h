//
//  VirtualPerson.h
//  TicTacToe
//
//  Created by Dennis Dixon on 5/18/14.
//  Copyright (c) 2014 Appivot LLC All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicTacToeBoard.h"

@class VirtualPerson;

@protocol VirtualPersonTicTacToeOpponent

@required
-(void)virtualPersonTicTacToeOpponent:(VirtualPerson *)vitualPerson selectSpace:(NSInteger)space;

@end


@interface VirtualPerson : NSObject

@property (strong,nonatomic) id delegate;
@property (weak,nonatomic) TicTacToeBoard *ticTacToeBoard;

-(void)rebootVirtualPerson;
-(id)initWithTicTacToeBoard:(TicTacToeBoard *)ticTacToeBoard;
-(void)takeTurn;


@end
