//
//  VirtualPerson.m
//  TicTacToe
//
//  Created by Dennis Dixon on 5/18/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "VirtualPerson.h"
#import "TicTacToeGlobalConstants.h"

@interface VirtualPerson ()

@property (nonatomic) NSInteger myTurnNumber;
@property (strong,nonatomic) NSArray *ticTacToeGridArray;

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
    self.ticTacToeGridArray = [ticTacToeBoard getTicTacToeBoardArray];
    return self;
}


-(void)takeTurn
{
    NSLog(@"I am virtual Dennis and it's my turn.");
    NSLog(@"The board looks like this: %@",[self.ticTacToeBoard getTicTacToeBoardArray]);

    if (self.delegate  && [self.delegate respondsToSelector:@selector(virtualPersonTicTacToeOpponent:selectSpace:)] )
    {
        NSInteger aiChosenSpace = [self analyzeBoardAndFindBestMove];
        if (aiChosenSpace != kSpaceNotFound)
            [self.delegate virtualPersonTicTacToeOpponent:self selectSpace:aiChosenSpace];
        else
            NSLog(@"Virtual Dennis failed to analyze the board!!!");
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Use Human Mode" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    self.myTurnNumber++;
}


// The basic approach is as follows:
//  --on the first move, take the center if open else take a corner
//  --on every other turn (2, 3, and 4) follow a decision tree based on these evaluations:
//      --can I win?  if yes, then win!
//      --must I block?  if yes, then block!
//      --are there any strategy-excluded spaces? if yes, then exclude them and then ask...
//      --can I build?  if yes, then build!
//      --if no, then select randomly
-(NSInteger)analyzeBoardAndFindBestMove
{
    NSLog(@"in analyzeBoardAndFindBestMove - gridArray contains %@",self.ticTacToeGridArray);
    if (self.myTurnNumber == 0)
    {
        if ([self.ticTacToeGridArray[4] isEqualToString:kEmptyNSString])
            return 4;  // the center space
        else
            return 2;  //  the second corner space
    }
    else
    {
        NSInteger winSpace = [self whereCanIWin];
        if (winSpace != kSpaceNotFound)
        {
            return winSpace;
        }
        else
        {
            NSInteger blockSpace = [self whereMustIBlock];
            if (blockSpace != kSpaceNotFound)
            {
                return blockSpace;
            }
            else
            {
                NSInteger buildSpace = [self whereMustIBlock];
                if (buildSpace != kSpaceNotFound)
                {
                    return blockSpace;
                }
                else // test for open corners first to avoid strategic exclusions or settle for sides
                {
                    if ([self.ticTacToeGridArray[8] isEqualToString:kEmptyNSString])
                        return 8;
                    else if ([self.ticTacToeGridArray[6] isEqualToString:kEmptyNSString])
                        return 6;
                    else if ([self.ticTacToeGridArray[2] isEqualToString:kEmptyNSString])
                        return 2;
                    else if ([self.ticTacToeGridArray[0] isEqualToString:kEmptyNSString])
                        return 0;
                    else if ([self.ticTacToeGridArray[6] isEqualToString:kEmptyNSString])
                        return 1;
                    else if ([self.ticTacToeGridArray[6] isEqualToString:kEmptyNSString])
                        return 3;
                    else if ([self.ticTacToeGridArray[6] isEqualToString:kEmptyNSString])
                        return 5;
                    else if ([self.ticTacToeGridArray[6] isEqualToString:kEmptyNSString])
                        return 7;
                }
            }
        }
    }
    return -1;
}


-(NSInteger)whereCanIWin
{
    return [self testForOpenSpaceWithPlayerSymbol:kPlayerTwoSymbol withPurpose:kPurposeToFindWinSpace];
}

-(NSInteger)whereMustIBlock
{
    return [self testForOpenSpaceWithPlayerSymbol:kPlayerOneSymbol withPurpose:kPurposeToFindWinSpace];
}

-(NSInteger)whereCanIBuild
{
    return [self testForOpenSpaceWithPlayerSymbol:kPlayerTwoSymbol withPurpose:kPurposeToFindBuildSpace];
}


-(void)rebootVirtualPerson
{
    self.myTurnNumber = 0;
}




- (NSInteger)testForOpenSpaceWithPlayerSymbol:(NSString *)playerSymbol withPurpose:(NSInteger)purpose
{

    NSInteger displacements[] = {0,3,4,2};
    NSInteger spacings[] = {3,1};

    for (NSInteger passIndex=0; passIndex<kBoardScanPasses; passIndex++)  // To make all 4 board scan passes
    {
        if (passIndex == 0) // scan three paths (3 scans for rows and 3 for columns) using the displacements and spacings
        {

            for (NSInteger pathSetIndex=0; pathSetIndex<3;pathSetIndex++) // outter for loop for the 3 paths
            {
                NSInteger numberOfHits = 0;
                NSInteger numberOfBlockages = 0;
                NSInteger openSpaceIndex = kSpaceNotFound;
                NSInteger adjustedIndex = 0;

                for (int pathIndex=0; pathIndex<3; pathIndex++) // To scan each row path on pass 0 and each col path on pass 1
                {
                    adjustedIndex = pathIndex + displacements[passIndex] + (pathSetIndex * spacings[passIndex]);

                    if ([self.ticTacToeGridArray[adjustedIndex] isEqualToString:playerSymbol])
                    {
                        numberOfHits++;
                    }
                    else if ([self.ticTacToeGridArray[adjustedIndex] isEqualToString:kEmptyNSString])
                    {
                        openSpaceIndex = adjustedIndex;
                    }
                    else
                    {
                        numberOfBlockages++;
                    }
                }  // End for loop for scanning the current path in the current set of paths in the current pass

                if (purpose == kPurposeToFindWinSpace)
                {
                    if ((numberOfHits == 2) && (numberOfBlockages == 0))
                        return openSpaceIndex;
                }
                else {
                    if ((numberOfHits > 0) && (numberOfBlockages == 0))
                        return openSpaceIndex;
                }
            } // End for loop for scanning all paths in the current pass
        }

        else if (passIndex == 1) // scan three paths (3 scans for rows and 3 for columns) using the displacements and spacings
        {
            for (NSInteger pathSetIndex=0; pathSetIndex<3;pathSetIndex++) // outter for loop for the 3 paths
            {
                NSInteger numberOfHits = 0;
                NSInteger numberOfBlockages = 0;
                NSInteger openSpaceIndex = kSpaceNotFound;
                NSInteger adjustedIndex = 0;

                for (int pathIndex=0; pathIndex<3; pathIndex++) // To scan each row path on pass 0 and each col path on pass 1
                {
                    adjustedIndex = pathSetIndex + (pathIndex * displacements[passIndex]);

                    if ([self.ticTacToeGridArray[adjustedIndex] isEqualToString:playerSymbol])
                    {
                        numberOfHits++;
                    }
                    else if ([self.ticTacToeGridArray[adjustedIndex] isEqualToString:kEmptyNSString])
                    {
                        openSpaceIndex = adjustedIndex;
                    }
                    else
                    {
                        numberOfBlockages++;
                    }
                }  // End for loop for scanning the current path in the current set of paths in the current pass

                if (purpose == kPurposeToFindWinSpace)
                {
                    if ((numberOfHits == 2) && (numberOfBlockages == 0))
                        return openSpaceIndex;
                }
                else {
                    if ((numberOfHits > 0) && (numberOfBlockages == 0))
                        return openSpaceIndex;
                }
            } // End for loop for scanning all paths in the current pass
        }


        else // only make one pass for each diagonal no need to use spacings
        {
            if (passIndex == 2)  // down-right diagonal path
            {
                NSInteger numberOfHits = 0;
                NSInteger numberOfBlockages = 0;
                NSInteger openSpaceIndex = kSpaceNotFound;
                NSInteger adjustedIndex = 0;

                for (int pathIndex=0; pathIndex<3; pathIndex++) // To scan each row path on pass 0 and each col path on pass 1
                {
                    adjustedIndex = (pathIndex * displacements[passIndex]);

                    if ([self.ticTacToeGridArray[adjustedIndex] isEqualToString:playerSymbol])
                    {
                        numberOfHits++;
                    }
                    else if ([self.ticTacToeGridArray[adjustedIndex] isEqualToString:kEmptyNSString])
                    {
                        openSpaceIndex = adjustedIndex;
                    }
                    else
                    {
                        numberOfBlockages++;
                    }
                }  // End for loop for scanning the current path in the current set of paths in the current pass

                if (purpose == kPurposeToFindWinSpace)
                {
                    if ((numberOfHits == 2) && (numberOfBlockages == 0))
                        return openSpaceIndex;
                }
                else {
                    if ((numberOfHits > 0) && (numberOfBlockages == 0))
                        return openSpaceIndex;
                }
            }   // end of down-right diagonal scan
            else
            {   // scan the down-left diagonal

                NSInteger numberOfHits = 0;
                NSInteger numberOfBlockages = 0;
                NSInteger openSpaceIndex = kSpaceNotFound;
                NSInteger adjustedIndex = 0;

                for (int pathIndex=0; pathIndex<3; pathIndex++) // To scan each row path on pass 0 and each col path on pass 1
                {
                    adjustedIndex = 2 + (pathIndex * displacements[passIndex]);

                    if ([self.ticTacToeGridArray[adjustedIndex] isEqualToString:playerSymbol])
                    {
                        numberOfHits++;
                    }
                    else if ([self.ticTacToeGridArray[adjustedIndex] isEqualToString:kEmptyNSString])
                    {
                        openSpaceIndex = adjustedIndex;
                    }
                    else
                    {
                        numberOfBlockages++;
                    }
                }  // End for loop for scanning the current path in the current set of paths in the current pass

                if (purpose == kPurposeToFindWinSpace)
                {
                    if ((numberOfHits == 2) && (numberOfBlockages == 0))
                        return openSpaceIndex;
                }
                else {
                    if ((numberOfHits > 0) && (numberOfBlockages == 0))
                        return openSpaceIndex;
                }

            }  // end of down-left diagonal scan
        }

    }
    return kSpaceNotFound;
}



@end
