//
//  TicTacToeBoard.h
//  TicTacToe
//
//  Created by Dennis Dixon on 5/18/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicTacToeGlobalConstants.h"


@interface TicTacToeBoard : NSObject

-(BOOL)isValidMoveToSpace:(NSInteger)space;
-(void)processValidatedMove:(NSString *)player toSpace:(NSInteger)space;
-(NSString *)whoWon;
-(void)initializeNewBoard;
-(BOOL)isBoardFilled;


@end
