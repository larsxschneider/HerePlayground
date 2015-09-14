//
//  LSHereAPI.m
//  HerePlayground
//
//  Created by Lars Schneider on 14/09/15.
//  Copyright (c) 2015 lars. All rights reserved.
//

#import "LSHereAPI.h"
#import <AFNetworking.h>
#import <INTULocationManager.h>

static NSString *LSHereAPIServer = @"cit.api.here.com";
static NSString *LSHereAPIAppID = @"DemoAppId01082013GAL";
static NSString *LSHereAPIAppCode = @"AJKnXv84fjrb0KIHawS0Tg";


@implementation LSHereAPI


+ (NSDictionary *)generateWaypoints:(NSArray *)itinerary {
    NSMutableDictionary *wayPoints = [[NSMutableDictionary alloc] initWithCapacity:itinerary.count];
    long i = 0;
    for (NSDictionary* wayPoint in itinerary) {
        [wayPoints setObject:[NSString stringWithFormat:@"%@,%@", wayPoint[@"position"][0], wayPoint[@"position"][1]]
                       forKey:[NSString stringWithFormat:@"waypoint%li", i]];
        i++;
    }
    return wayPoints;
}


+ (MKPolyline *)generatePolyline:(NSArray *)shape {
    NSInteger i = 0;
    CLLocationCoordinate2D routeCoord[shape.count];
    for (NSString *wayPoint in shape) {
        NSArray *coords = [wayPoint componentsSeparatedByString:@","];
        routeCoord[i] = CLLocationCoordinate2DMake([coords[0] floatValue], [coords[1] floatValue]);
        i++;
    }
    return [MKPolyline polylineWithCoordinates:routeCoord count:shape.count];
}


+ (MKCoordinateRegion)generateRegion:(NSArray *)shape {
    CLLocationCoordinate2D max;
    CLLocationCoordinate2D min;
    BOOL init = false;
    for (NSString *wayPoint in shape) {
        NSArray *coords = [wayPoint componentsSeparatedByString:@","];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([coords[0] floatValue], [coords[1] floatValue]);
        if (!init) {
            init = true;
            max = location;
            min = location;
        } else {
            if (location.latitude > max.latitude) max.latitude = location.latitude;
            else if (location.latitude < min.latitude) min.latitude = location.latitude;
            if (location.longitude > max.longitude) max.longitude = location.longitude;
            else if (location.longitude < min.longitude) min.longitude = location.longitude;
        }
    }

    MKCoordinateRegion region;
    region.center.latitude = (max.latitude + min.latitude) / 2;
    region.center.longitude = (max.longitude + min.longitude) / 2;
    region.span.latitudeDelta = (max.latitude - min.latitude) * 1.5;
    region.span.longitudeDelta = (max.longitude - min.longitude) * 1.5;
    return region;
}


+ (void)calcRoute:(NSArray* )itinerary
          success:(void (^)(MKPolyline *, MKCoordinateRegion))success
          failure:(void (^)(void))failure {

    NSMutableDictionary *parameters = [
        @{
            @"mode": @"fastest;car;traffic:disabled",
            @"routeAttributes": @"sh,wp",
            @"app_id": LSHereAPIAppID,
            @"app_code": LSHereAPIAppCode,
        } mutableCopy
    ];
    [parameters addEntriesFromDictionary:[[self class] generateWaypoints:itinerary]];

    NSString *URLString = [NSString stringWithFormat:@"https://route.%@/routing/7.2/calculateroute.json", LSHereAPIServer];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:URLString
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSArray* shape = responseObject[@"response"][@"route"][0][@"shape"];
             success([[self class] generatePolyline:shape], [[self class] generateRegion:shape]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             failure();
         }
     ];
}


+ (void)searchAtCoordinate:(CLLocationCoordinate2D)coordinate
                 withQuery:(NSString *)query
                   success:(void (^)(NSArray *results))success
                   failure:(void (^)(void))failure {
    NSString *URLString = [NSString stringWithFormat:@"https://places.%@/places/v1/discover/search", LSHereAPIServer];
    NSDictionary *parameters = @{
        @"at": [NSString stringWithFormat:@"%f,%f",
             coordinate.latitude,
             coordinate.longitude
             ],
        @"q": query,
        @"app_id": LSHereAPIAppID,
        @"app_code": LSHereAPIAppCode
    };

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:URLString
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject[@"results"][@"items"]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             failure();
         }
     ];
}


+ (void)searchWithQuery:(NSString *)query
                success:(void (^)(NSArray *results))success
                failure:(void (^)(void))failure {
    INTULocationManager *locationManager = [INTULocationManager sharedInstance];
    [locationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                                timeout:10.0
                                   delayUntilAuthorized:YES
                                                  block:^(CLLocation *currentLocation,
                                                          INTULocationAccuracy achievedAccuracy,
                                                          INTULocationStatus status) {
                                                      if (status == INTULocationStatusSuccess) {
                                                          [[self class] searchAtCoordinate:currentLocation.coordinate
                                                                         withQuery:query
                                                                           success:success
                                                                           failure:failure];
                                                      }
                                                      else {
                                                          failure();
                                                      }
                                                  }];
}


@end
