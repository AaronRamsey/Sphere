//
//  EventController.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "EventController.h"
#import "FriendsAtEventController.h"
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "ReviewsController.h"

@interface EventController ()
- (IBAction)onBack:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *eventLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIImageView *yellowImage;
- (IBAction)onDirections:(id)sender;
- (IBAction)onReviews:(id)sender;
- (IBAction)onCloseReviews:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *reviewView;

@end

@implementation EventController {
    FriendsAtEventController *friendsTable;
    ReviewsController *reviewTable;
}
@synthesize event;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.eventLabel.text = [event objectForKey:@"EventName"];
    self.descriptionLabel.text = [event objectForKey:@"Description"];
    //self.reviewView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(animationCode) withObject:nil afterDelay:0.0f];
    [self updateMapZoomLocation];
    
}

- (void)animationCode {
    float n = [[event objectForKey:@"Rating"] floatValue] * 32;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    self.yellowImage.frame = CGRectMake(80,350,n,40);
    [UIView commitAnimations];
}

- (void)updateMapZoomLocation
{
    MKCoordinateRegion region;
    PFGeoPoint *point = [event objectForKey:@"Location"];
    region.center.latitude = point.latitude;
    region.center.longitude = point.longitude;
    MKPointAnnotation *pin = [[MKPointAnnotation alloc]init];
    pin.coordinate = region.center;
    [self.mapView addAnnotation:pin];
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    [self.mapView setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FriendsAtEventEmbed"]) {
        friendsTable = segue.destinationViewController;
        friendsTable.friends = [event objectForKey:@"Attendees"];
    } else if ([segue.identifier isEqualToString:@"reviewsEmbed"]) {
        reviewTable = segue.destinationViewController;
        reviewTable.reviews = [event objectForKey:@"Reviews"];
    }
}

- (IBAction)onBack:(id)sender {
    [self performSegueWithIdentifier:@"fromEventToFeedSegue" sender:self];
}
- (IBAction)onDirections:(id)sender {
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        PFGeoPoint *geoPoint = [event objectForKey:@"Location"];
        CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:@"Destination"];
        
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
}

- (IBAction)onReviews:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.reviewView.frame = CGRectMake(10,115,300,453);
    [UIView commitAnimations];
}

- (IBAction)onCloseReviews:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.reviewView.frame = CGRectMake(10,568,300,453);
    [UIView commitAnimations];
}
@end
