//
//  HerePlaygroundTests.m
//  HerePlaygroundTests
//
//  Created by Lars Schneider on 14/09/15.
//  Copyright (c) 2015 lars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LSHereAPI.h"


@interface HerePlaygroundTests : XCTestCase

@end


@implementation HerePlaygroundTests


- (void)testWaypointGeneration {
    NSArray *itinerary = @[
        @{@"position":@[@1,@2]},
        @{@"position":@[@3,@4]}
    ];
    NSDictionary *actual = [LSHereAPI generateWaypoints:itinerary];
    NSDictionary *expected = @{@"waypoint0": @"1,2", @"waypoint1": @"3,4"};
    XCTAssertEqualObjects(actual, expected);
}


- (void)test2WaypointGeneration {
    NSArray *shape = @[@"52.4999824,13.3999652",@"52.4973321,13.4487462"];
    MKPolyline *actual = [LSHereAPI generatePolyline:shape];
    // Not a good test because I don't know what projection is applied here...
    XCTAssertEqualWithAccuracy(actual.points[0].x, 144209466.311, .001);
    XCTAssertEqualWithAccuracy(actual.points[0].y, 88059319.4901, .001);
    XCTAssertEqualWithAccuracy(actual.points[1].x, 144245839.644, .001);
    XCTAssertEqualWithAccuracy(actual.points[1].y, 88062562.1137, .001);
}


@end
