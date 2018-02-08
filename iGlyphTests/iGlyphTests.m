//
//  iGlyphTests.m
//  iGlyphTests
//
//  Created by Ivan Subotic on 08.02.18.
//

#import <XCTest/XCTest.h>
#import "IGlyphDelegate.h"
#import "IGDrawWindowController.h"
#import "IGGraphicView.h"


@interface iGlyphTests : XCTestCase {

@private
    NSApplication           *app;
    IGlyphDelegate          *appDelegate;
    IGDrawWindowController  *drawWindowController;
    IGGraphicView           *graphicView;
}
@end

@implementation iGlyphTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testSomething {
    app                  = [NSApplication sharedApplication];
    appDelegate          = (IGlyphDelegate *)[app delegate];
}

@end
