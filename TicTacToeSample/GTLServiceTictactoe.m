/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2012 Google Inc.
 */

//
//  GTLServiceTictactoe.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   tictactoe/v1
// Classes:
//   GTLServiceTictactoe (0 custom class methods, 0 custom properties)

#import "GTLTictactoe.h"

@implementation GTLServiceTictactoe

#if DEBUG
// Method compiled in debug builds just to check that all the needed support
// classes are present at link time.
+ (NSArray *)checkClasses {
  NSArray *classes = [NSArray arrayWithObjects:
                      [GTLQueryTictactoe class],
                      [GTLTictactoeBoard class],
                      [GTLTictactoeScore class],
                      [GTLTictactoeScores class],
                      [GTLTictactoeUser class],
                      nil];
  return classes;
}
#endif  // DEBUG

- (id)init {
  self = [super init];
  if (self) {
    // Version from discovery.
    self.apiVersion = @"v1";

    // From discovery.  Where to send JSON-RPC.
    // Turn off prettyPrint for this service to save bandwidth (especially on
    // mobile). The fetcher logging will pretty print.
    self.rpcURL = [NSURL URLWithString:@"https://your_app_id.appspot.com/_ah/api/rpc?prettyPrint=false"];
  }
  return self;
}

@end
