//
//  AnnotationView.h
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AnnotationView : NSObject <MKAnnotation>

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;

-(id)initWithTitle:(NSString*)title Location:(CLLocationCoordinate2D)location;
-(MKAnnotationView*)getView;

@end
