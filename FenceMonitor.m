//
//  FenceMonitor.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "FenceMonitor.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>

@implementation FenceMonitor {
    float longitude;
    float latitude;
    NSMutableArray *events;
    PFObject *currentEvent;
}
@synthesize locationManager;
+(FenceMonitor*)getMonitor {
    static FenceMonitor * shared =nil;
    
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        shared = [[FenceMonitor alloc] init];
    });
    return shared;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyBest;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.pausesLocationUpdatesAutomatically = NO;
        events = [[NSMutableArray alloc]init];
    }
    return self;
}

- (PFObject*)getCurrentEvent {
    for (int x = 0; x < [events count]; x++) {
        PFObject *event = [[events objectAtIndex:x] objectAtIndex:1];
        NSMutableArray *attendees = [event objectForKey:@"Attendees"];
        if ([attendees containsObject:[[PFUser currentUser] objectForKey:@"FacebookName"]]) {
            return event;
        }
    }
    return nil;

}

-(void) showMessage:(NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Geofence"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:Nil, nil];
    
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    
    [alertView show];
    
    
}

-(BOOL) checkLocationManager
{

    return TRUE;
}
-(void) startFencing
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    
    if([version floatValue] >= 7.0f) //for iOS7
    {
        NSArray * monitoredRegions = [locationManager.monitoredRegions allObjects];
        for(CLRegion *region in monitoredRegions)
        {
            NSLog(@"%hhd",[CLLocationManager isMonitoringAvailableForClass:region.class]);
            
            [locationManager requestStateForRegion:region];
        }
    } else {
        [locationManager startUpdatingLocation];
    }

    
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if(state == CLRegionStateInside)
    {
        NSLog(@"##Entered Region - %@", region.identifier);
    }
    else if(state == CLRegionStateOutside)
    {
        NSLog(@"##Exited Region - %@", region.identifier);
    }
    else{
        NSLog(@"##Unknown state  Region - %@", region.identifier);
    }
}

-(void)addFence:(CLRegion*)region andEvent:(PFObject*)event{
    [events addObject:@[region,event]];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    [locationManager startMonitoringForRegion:region];
    
}
-(void)removeAllFences {
    NSArray * monitoredRegions = [locationManager.monitoredRegions allObjects];
    for(CLRegion *region in monitoredRegions) {
        [locationManager stopMonitoringForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    static BOOL firstTime = YES;
    latitude = newLocation.coordinate.latitude;
    longitude = newLocation.coordinate.longitude;
    if(firstTime)
    {
        firstTime = NO;
        NSSet * monitoredRegions = locationManager.monitoredRegions;
        if(monitoredRegions)
        {
            [monitoredRegions enumerateObjectsUsingBlock:^(CLCircularRegion *region,BOOL *stop)
             {
                 NSString *identifer = region.identifier;
                 if([region containsCoordinate:newLocation.coordinate])
                 {
                     NSLog(@"Invoking didEnterRegion Manually for region: %@",identifer);
                     
                     [locationManager stopMonitoringForRegion:region];
                     
                     [self locationManager:locationManager didEnterRegion:region];

                     [locationManager startMonitoringForRegion:region];
                 }
             }];
        }
        [locationManager stopUpdatingLocation];
        
    }
}

-(void)updateFences {
    CLLocationManager *manager = [[CLLocationManager alloc]init];
    CLLocationCoordinate2D coord = [manager location].coordinate;
    BOOL removeOthers = NO;
    for (int x = 0; x < [events count]; x++) {
        CLCircularRegion *region = [[events objectAtIndex:x] objectAtIndex:0];
        if ([region containsCoordinate:coord] && !removeOthers) {
            PFObject *event = [[events objectAtIndex:x] objectAtIndex:1];
            NSMutableArray *attendees = [event objectForKey:@"Attendees"];
            if (![attendees containsObject:[[PFUser currentUser] objectForKey:@"FacebookName"]]) {
                [attendees addObject:[[PFUser currentUser] objectForKey:@"FacebookName"]];
            }
            [event setObject:attendees forKey:@"Attendees"];
            [event saveInBackground];
            removeOthers = YES;
        } else {
            PFObject *event = [[events objectAtIndex:x] objectAtIndex:1];
            NSMutableArray *attendees = [event objectForKey:@"Attendees"];
            if ([attendees containsObject:[[PFUser currentUser] objectForKey:@"FacebookName"]]) {
                [attendees removeObject:[[PFUser currentUser] objectForKey:@"FacebookName"]];
                [event setObject:attendees forKey:@"Attendees"];
                [event saveInBackground];
            }
        }
    }
}

-(void)removeFences {
    for (int x = 0; x < [events count]; x++) {
        PFObject *event = [[events objectAtIndex:x] objectAtIndex:1];
        NSMutableArray *attendees = [event objectForKey:@"Attendees"];
        if ([attendees containsObject:[[PFUser currentUser] objectForKey:@"FacebookName"]]) {
            [attendees removeObject:[[PFUser currentUser] objectForKey:@"FacebookName"]];
            [event setObject:attendees forKey:@"Attendees"];
            [event saveInBackground];
        }
    }
    [events removeAllObjects];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"%@",error.description);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Started monitoring %@ region", region.identifier);
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"METHOD CALL: Entered Region - %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"METHOD CALL: Exited Region - %@", region.identifier);
}

@end
