//
//  ViewController.m
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

#import "ViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLTictactoe.h"

@implementation ViewController

@synthesize userLabel;
@synthesize victory;

@synthesize signInButton;
@synthesize restartButton;
@synthesize topLeft;
@synthesize topMiddle;
@synthesize topRight;
@synthesize middleLeft;
@synthesize middleMiddle;
@synthesize middleRight;
@synthesize bottomLeft;
@synthesize bottomMiddle;
@synthesize bottomRight;

@synthesize gameHistory;
@synthesize gameData;

static NSString *const kKeychainItemName = @"App Engine APIs Sample: TicTacToe";
NSString *kMyClientID = @"your_web_client_id"; // pre-assigned by service
NSString *kMyClientSecret = @"your_web_client_secret"; // pre-assigned by service

NSString *scope = @"https://www.googleapis.com/auth/userinfo.email"; // scope for email

bool signedIn = false;
bool waitingForMove = true;

static const int NOT_DONE = 0;
static const int WON = 1;
static const int LOST = 2;
static const int TIE = 3;
NSString * const statusStrings[] = {
    @"NOT DONE",
    @"WON",
    @"LOST",
    @"TIE"
};

// Button actions.

- (IBAction)signin:(UIBarButtonItem *)sender {
    if (!signedIn) {
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                    clientID:kMyClientID
                                                                clientSecret:kMyClientSecret
                                                            keychainItemName:kKeychainItemName
                                                                    delegate:self
                                                            finishedSelector:@selector(viewController:finishedWithAuth:error:)];

        [self presentModalViewController:viewController
                                animated:YES];
    } else {
        signedIn = false;
        [userLabel setText:@""];
        [signInButton setTitle:@"Sign in"];
        [self setBoardEnablement:false];
    }
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];

    if (error != nil) {
        // Authentication failed
        [signInButton setTitle:@"Retry"];
    } else {
        // Authentication succeeded
        signedIn = true;
        [[self tictactoeService] setAuthorizer:auth];
        auth.authorizationTokenKey = @"id_token";
        [userLabel setText:auth.userEmail];
        [signInButton setTitle:@"Sign out"];
        [victory setText:@""];
        [self setBoardEnablement:true];
        [self queryScores];
    }
}

- (IBAction)clickSquare:(id)sender {
    if (waitingForMove && [[sender currentTitle] isEqualToString:@"-"]) {
        [sender setTitle:@"X" forState:UIControlStateNormal];
        waitingForMove = false;
        NSString *boardString = [self getBoardString];

        int status = [self checkForVictory:boardString];
        if (status == NOT_DONE) {
            [self getComputerMove:boardString];
        } else {
            [self handleFinish:status];
        }
    }
}

- (IBAction)resetGame:(id)sender {
    [self setBoardFilling:@"---------"];
    [victory setText:@""];
    waitingForMove = true;
}

// Remote API handling.

- (GTLServiceTictactoe *)tictactoeService {
    static GTLServiceTictactoe *service = nil;
    if (!service) {
        service = [[GTLServiceTictactoe alloc] init];

        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;

        [GTMHTTPFetcher setLoggingEnabled:YES];
    }
    return service;
}

- (void)getComputerMove:(NSString *)boardString {
    GTLServiceTictactoe *service = [self tictactoeService];

    GTLTictactoeBoard *board = [GTLTictactoeBoard alloc];
    [board setState:boardString];
    GTLQueryTictactoe *query = [GTLQueryTictactoe queryForBoardGetmoveWithObject:board];

    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLTictactoeBoard *object, NSError *error) {
        NSString *boardString = [object state];
        [self setBoardFilling:boardString];

        int status = [self checkForVictory:boardString];
        if (status != 0) {
            [self handleFinish:status];
        } else {
            waitingForMove = true;
        }
    }];
}

- (void)sendResultToServer:(int)status {
    GTLServiceTictactoe *service = [self tictactoeService];

    GTLTictactoeScore *score = [GTLTictactoeScore alloc];
    [score setOutcome:statusStrings[status]];
    GTLQueryTictactoe *query = [GTLQueryTictactoe queryForScoresInsertWithObject:score];

    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLObject *object, NSError *error) {
        [self queryScores];
    }];
}

- (void)queryScores {
    GTLServiceTictactoe *service = [self tictactoeService];
    GTLQueryTictactoe *query = [GTLQueryTictactoe queryForScoresList];

    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLTictactoeScores *object, NSError *error) {
        NSArray *items = [object items];
        [gameData removeAllObjects];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [gameData addObject:[obj valueForKey:@"outcome"]];
        }];
        [gameHistory reloadData];
    }];
}

// Board state handling.

- (void)setBoardEnablement:(bool)state {
    [restartButton setEnabled:state];
    [restartButton setHidden:!state];
    [topLeft setEnabled:state];
    [topLeft setHidden:!state];
    [topMiddle setEnabled:state];
    [topMiddle setHidden:!state];
    [topRight setEnabled:state];
    [topRight setHidden:!state];
    [middleLeft setEnabled:state];
    [middleLeft setHidden:!state];
    [middleMiddle setEnabled:state];
    [middleMiddle setHidden:!state];
    [middleRight setEnabled:state];
    [middleRight setHidden:!state];
    [bottomLeft setEnabled:state];
    [bottomLeft setHidden:!state];
    [bottomMiddle setEnabled:state];
    [bottomMiddle setHidden:!state];
    [bottomRight setEnabled:state];
    [bottomRight setHidden:!state];
    [victory setHidden:!state];
    [gameHistory setHidden:!state];
}

- (void)setBoardFilling:(NSString *)boardString {
    [topLeft setTitle:[self getStringAtPosition:boardString:0]
             forState:UIControlStateNormal];
    [topMiddle setTitle:[self getStringAtPosition:boardString:1]
               forState:UIControlStateNormal];
    [topRight setTitle:[self getStringAtPosition:boardString:2]
              forState:UIControlStateNormal];
    [middleLeft setTitle:[self getStringAtPosition:boardString:3]
                forState:UIControlStateNormal];
    [middleMiddle setTitle:[self getStringAtPosition:boardString:4]
                  forState:UIControlStateNormal];
    [middleRight setTitle:[self getStringAtPosition:boardString:5]
                 forState:UIControlStateNormal];
    [bottomLeft setTitle:[self getStringAtPosition:boardString:6]
                forState:UIControlStateNormal];
    [bottomMiddle setTitle:[self getStringAtPosition:boardString:7]
                  forState:UIControlStateNormal];
    [bottomRight setTitle:[self getStringAtPosition:boardString:8]
                 forState:UIControlStateNormal];
}

// Victory condition checking.

- (int)checkForVictory:(NSString *)board {
    int status = 0;

    // Check rows and columns.
    for (int i = 0; i < 3; i++) {
        NSString *rowString = [self getStringsAtPositions:board:(i*3):(i*3)+1:(i*3)+2];
        status |= [self checkSectionVictory:rowString];

        NSString *colString = [self getStringsAtPositions:board:i:i+3:i+6];
        status |= [self checkSectionVictory:colString];
    }

    // Check top-left to bottom-right.
    NSString *diagonal = [self getStringsAtPositions:board:0:4:8];
    status |= [self checkSectionVictory:diagonal];

    // Check top-right to bottom-left.
    diagonal = [self getStringsAtPositions:board:2:4:6];
    status |= [self checkSectionVictory:diagonal];

    if (status == 0) {
        NSRange range = [board rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
        if (range.location == NSNotFound) {
            return TIE;
        }
    }
    return status;
}

- (int)checkSectionVictory:(NSString *)row {
    char a = [row characterAtIndex:0];
    char b = [row characterAtIndex:1];
    char c = [row characterAtIndex:2];
    if (a == b && a == c) {
        if (a == 'X') {
            return WON;
        } else if (a == 'O') {
            return LOST;
        }
    }
    return NOT_DONE;
}

- (void)handleFinish:(int)status {
    if (status == WON) {
        [victory setText:@"You win!"];
    } else if (status == LOST) {
        [victory setText:@"You lose!"];
    } else {
        [victory setText:@"You tied!"];
    }
    [self sendResultToServer:status];
}

// Board utility methods.

- (NSString *)getBoardString {
    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
     [topLeft currentTitle],
     [topMiddle currentTitle],
     [topRight currentTitle],
     [middleLeft currentTitle],
     [middleMiddle currentTitle],
     [middleRight currentTitle],
     [bottomLeft currentTitle],
     [bottomMiddle currentTitle],
     [bottomRight currentTitle]];
}


- (NSString *)getStringAtPosition:(NSString *)string
                                 :(int)position {
    return [NSString stringWithFormat:@"%C", [string characterAtIndex:position]];
}

- (NSString *)getStringsAtPositions:(NSString *)string
                                   :(int)first
                                   :(int)second
                                   :(int)third {
    return [NSString stringWithFormat:@"%@%@%@",
     [self getStringAtPosition:string:first],
     [self getStringAtPosition:string:second],
     [self getStringAtPosition:string:third]];
}

// View delegates.

- (void)viewDidLoad {
    [self setBoardEnablement:false];
    gameData = [[NSMutableArray alloc] init];
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setSignInButton:nil];
    [self setTopLeft:nil];
    [self setTopMiddle:nil];
    [self setTopRight:nil];
    [self setMiddleLeft:nil];
    [self setMiddleMiddle:nil];
    [self setMiddleRight:nil];
    [self setBottomLeft:nil];
    [self setBottomMiddle:nil];
    [self setBottomRight:nil];
    [self setRestartButton:nil];
    [self setVictory:nil];
    [self setSignInButton:nil];
    [self setSignInButton:nil];
    [self setGameHistory:nil];
    [super viewDidUnload];
}

// Table view delegates.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [gameData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Previous games";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 20.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryNone;
    [[cell textLabel] setText:[gameData objectAtIndex:[indexPath row]]];
    return cell;
}
@end
