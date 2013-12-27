//
//  AnnotationView.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "AnnotationView.h"

@implementation AnnotationView

-(id)initWithTitle:(NSString *)title Location:(CLLocationCoordinate2D)location {
    self = [super init];
    if (self) {
        _title = title;
        _coordinate = location;
    }
    return self;
}

-(MKAnnotationView*)getView {
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"AnnotationView"];
    view.enabled = YES;
    view.canShowCallout = YES;
    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return view;
}

@end
