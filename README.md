appengine-endpoints-tictactoe-ios
=================================

This application implements a simple client for a Tic Tac Toe game using
Google Cloud Endpoints, App Engine, Objective-C, and iOS.

It relies on a copy of the [Google APIs Client Library for Objective-C][1].

This example also uses ARC. If your application uses ARC, you must set the
-fno-objc-arc for the files included in the client library. To do this, in
Project Navigator -> Target -> Build Phases -> Compile Sources, set the
-fno-objc-arc compiler flag for each of the client library sources.

**NOTE:** This sample was written with a Java backend in mind. As a result, 
the generated code will differ slightly than that for the [Python Tic Tac
Toe sample][8]. For the most part this will be immaterial to the sample,
but there are a few key differences:
- The generated schema names in the discovery document are different in Python
  than in Java, even though the hold the same data. This will cause the generated
  classes corresponding to the schema to have different names.
- Python supports enums and uses `'WHEN'` and `'TEXT'` for the `order` field in
  queries, while Java simply uses `"1"` and `"2"`, respectively.
- The Python backend stores the current user for authenticated requests, but does
  not return the user in the score insert response or score list response.

## Products
- [App Engine][2]
- [iOS][3]

## Language
- [Objective-C][4]

## APIs
- [Google Cloud Endpoints][5]

## Setup Instructions
1. Open `TicTacToeSample.xcodeproj` in Xcode.
2. Modify `kMyClientId` and `kMyClientSecret` in `ViewController.m` to include
   the web client ID and client secret you registered in the [APIs Console][6].
3. Modify `GTLServiceTictactoe.m` (line 44) to point to the location where you
   are hosting a Tic Tac Toe backend (based off of the
   [Java backend example][7]).
4. Run the application.


[1]: http://code.google.com/p/google-api-objectivec-client/
[2]: https://developers.google.com/appengine
[3]: https://developer.apple.com/technologies/ios/
[4]: http://en.wikipedia.org/wiki/Objective-C
[5]: https://developers.google.com/appengine/docs/java/endpoints/
[6]: https://code.google.com/apis/console
[7]: https://github.com/GoogleCloudPlatform/appengine-endpoints-tictactoe-java
[8]: https://github.com/GoogleCloudPlatform/appengine-endpoints-tictactoe-python
