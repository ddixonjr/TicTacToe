//
//  VirtualPerson.m
//  TicTacToe
//
//  Created by Dennis Dixon on 5/18/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "VirtualPerson.h"

@implementation VirtualPerson

-(id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeMyTurn) name:@"TTTVirtualPersonTurnNotification" object:nil];
    }

    return self;
}

@end
