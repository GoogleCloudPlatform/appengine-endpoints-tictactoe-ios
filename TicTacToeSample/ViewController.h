//
//  ViewController.h
//  TicTacToeSample
//
//  Created by Dan Holevoet on 2/24/12.
//  Copyright 2012 Google Inc. All Rights Reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLTictactoe.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *victory;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UIButton *topLeft;
@property (weak, nonatomic) IBOutlet UIButton *topMiddle;
@property (weak, nonatomic) IBOutlet UIButton *topRight;
@property (weak, nonatomic) IBOutlet UIButton *middleLeft;
@property (weak, nonatomic) IBOutlet UIButton *middleMiddle;
@property (weak, nonatomic) IBOutlet UIButton *middleRight;
@property (weak, nonatomic) IBOutlet UIButton *bottomLeft;
@property (weak, nonatomic) IBOutlet UIButton *bottomMiddle;
@property (weak, nonatomic) IBOutlet UIButton *bottomRight;

@property (weak, nonatomic) IBOutlet UITableView *gameHistory;
@property (retain, nonatomic) NSMutableArray *gameData;

// Remote API handling.
- (GTLServiceTictactoe *)tictactoeService;
- (void)getComputerMove:(NSString *)boardString;
- (void)sendResultToServer:(int)status;
- (void)queryScores;

// Board state handling.
- (void)setBoardEnablement:(bool)state;
- (void)setBoardFilling:(NSString *)boardString;

// Victory condition checking.
- (int)checkForVictory:(NSString *)board;
- (int)checkSectionVictory:(NSString *)row;
- (void)handleFinish:(int)status;

// Board utility methods.
- (NSString *)getBoardString;
- (NSString *)getStringAtPosition:(NSString *)string
                                 :(int)position;
- (NSString *)getStringsAtPositions:(NSString *)string
                                   :(int)first
                                   :(int)second
                                   :(int)third;

@end
