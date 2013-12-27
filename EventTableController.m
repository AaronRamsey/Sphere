//
//  EventTableController.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "EventTableController.h"
#import <Parse/Parse.h>
#import "EventCell.h"
#import "EventController.h"

@interface EventTableController ()

@end

@implementation EventTableController{
    
    PFUser *user;
    NSMutableArray *eventList;
    //NSMutableArray *answeredList;
    //BOOL currentQAns;
    PFObject *currentEvent;
    PFGeoPoint *currentPoint;
    CLLocation *loc;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pullToRefreshEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    eventList = [[NSMutableArray alloc]init];
    //answeredList = [[NSMutableArray alloc]init];
    //boolList = [[NSMutableArray alloc]init];
    //[self refreshControl];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    user = [PFUser currentUser];
    [self queryForTable];
    [self loadObjects];
    [self refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (PFQuery*)queryForTable {
    if (user) {
        
        CLLocationManager *manager = [[CLLocationManager alloc]init];
        loc = [manager location];
        currentPoint = [PFGeoPoint geoPointWithLocation:loc];
        PFQuery *eventQueryPublic = [PFQuery queryWithClassName:@"Event"];
        [eventQueryPublic whereKey:@"Public" equalTo:@1];
        
        PFQuery *eventQueryPrivate = [PFQuery queryWithClassName:@"Event"];
        [eventQueryPrivate whereKey:@"Invited" equalTo:[[PFUser currentUser] objectForKey:@"FacebookID"]];
        
        PFQuery *eventQueryHost = [PFQuery queryWithClassName:@"Event"];
        [eventQueryHost whereKey:@"HostID" equalTo:[[PFUser currentUser] objectForKey:@"FacebookID"]];
        
        PFQuery *eventQuery = [PFQuery orQueryWithSubqueries:@[eventQueryPrivate,eventQueryPublic,eventQueryHost]];
        eventQuery.limit = 10;
        [eventQuery whereKey:@"Location" nearGeoPoint:currentPoint];
        if (self.pullToRefreshEnabled) {
            eventQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        }
        if (self.objects.count == 0) {
            eventQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
        return eventQuery;
    }
    return NULL;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    
    [eventList removeAllObjects];
    for (PFObject *object in self.objects) {
        [eventList addObject:object];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    
    static NSString *CellIdentifier = @"EventCell";
    
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.eventLabel.text = [object objectForKey:@"EventName"];
    cell.ratingLabel.text = [NSString stringWithFormat:@"Rating: %.1f",[[object objectForKey:@"Rating"] floatValue]];
    PFGeoPoint *point = [object objectForKey:@"Location"];
    CLLocation *tempLoc = [[CLLocation alloc]initWithLatitude:point.latitude longitude:point.longitude];
    cell.distanceLabel.text = [NSString stringWithFormat:@"Distance: %.2f miles",[loc distanceFromLocation:tempLoc] / 1000 / 1.6];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentEvent = eventList[indexPath.row];
    [self performSegueWithIdentifier:@"fromTableToEventSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromTableToEventSegue"]) {
        EventController *destViewController = segue.destinationViewController;
        destViewController.event = currentEvent;
    }
}

@end