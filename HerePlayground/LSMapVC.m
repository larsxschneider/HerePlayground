//
//  LSMapVC.m
//  HerePlayground
//
//  Created by Lars Schneider on 14/09/15.
//  Copyright (c) 2015 lars. All rights reserved.
//

#import "LSMapVC.h"
#import "LSHereAPI.h"


@interface LSMapVC () <MKMapViewDelegate>
@end


@implementation LSMapVC


- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRoute:)
                                                 name:@"ItineraryChange"
                                               object:nil];
}


- (void)updateRoute:(NSNotification *)notification {
    [self.mapView removeOverlays:self.mapView.overlays];
    
    NSArray* itinerary = notification.userInfo[@"itinerary"];
    if (itinerary.count < 2) {
        NSLog(@"Route requires at least two way points.");
        return;
    }

    [LSHereAPI calcRoute:itinerary
                 success:^(MKPolyline *polyline, MKCoordinateRegion region) {
                     [self.mapView addOverlay:polyline level:MKOverlayLevelAboveRoads];
                     [self.mapView setRegion:region animated:NO];
                 }
                 failure:^() {
                     [[[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:@"Route request failed."
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil] show];
                 }
    ];
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 3.0;
    return renderer;
}


@end
