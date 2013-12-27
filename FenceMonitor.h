//
//  FenceMonitor.h
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface FenceMonitor : NSObject <CLLocationManagerDelegate>
+(FenceMonitor*)getMonitor;
-(void)addFence:(CLRegion*)region andEvent:(PFObject*)event;
-(void)removeAllFences;
-(void)startFencing;
-(BOOL)checkLocationManager;
-(PFObject*)getCurrentEvent;
@property (strong,nonatomic) CLLocationManager* locationManager;
-(void)updateFences;
-(void)removeFences;
@end
