//
//  LSHereAPI.h
//  HerePlayground
//
//  Created by Lars Schneider on 14/09/15.
//  Copyright (c) 2015 lars. All rights reserved.
//
//  API wrapper for here API
//
//  Place API:
//  https://developer.here.com/rest-apis/documentation/places/topics/user-guide.html
//
//  Routing API:
//  https://developer.here.com/rest-apis/documentation/routing/topics/user-guide.html
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface LSHereAPI : NSObject

// API methods
+ (void)calcRoute:(NSArray* )itinerary
          success:(void (^)(MKPolyline *, MKCoordinateRegion))success
          failure:(void (^)(void))failure;
+ (void)searchWithQuery:(NSString *)query
                success:(void (^)(NSArray *results))success
                failure:(void (^)(void))failure;
+ (void)searchAtCoordinate:(CLLocationCoordinate2D)coordinate
                 withQuery:(NSString *)query
                   success:(void (^)(NSArray *results))success
                   failure:(void (^)(void))failure;

// Helper methods
+ (NSDictionary *)generateWaypoints:(NSArray *)itinerary;
+ (MKPolyline *)generatePolyline:(NSArray *)shape;
+ (MKCoordinateRegion)generateRegion:(NSArray *)shape;

@end
