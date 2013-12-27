//
//  FeedController.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "FeedController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "AnnotationView.h"
#import "FenceMonitor.h"
#import "SmokeCell.h"

@interface FeedController ()
@property (strong, nonatomic) IBOutlet UISegmentedControl *tabBar;
- (IBAction)didChangeTab:(id)sender;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *eventContainer;
@property (strong, nonatomic) IBOutlet UIView *currentView;
- (IBAction)onLogout:(id)sender;
- (IBAction)onCreate:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *currentEventLabel;
@property (strong, nonatomic) IBOutlet UIView *iconView;
@property (strong, nonatomic) IBOutlet UILabel *currentEventDescription;
@property (strong, nonatomic) IBOutlet UISlider *ratingSlider;
- (IBAction)onSubmitRating:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *submitRatingButton;
@property (strong, nonatomic) IBOutlet UITextField *reviewField;
- (IBAction)onSubmitReview:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *submitReviewButton;

@end

@implementation FeedController {
    PFGeoPoint *currentPoint;
    CLLocationCoordinate2D userCoord;
    NSMutableArray *events;
    BOOL first;
    NSTimer *timer;
}

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
    
    self.tabBar.selectedSegmentIndex = 0;
    [self didChangeTab:self];
    first = YES;
    CGRect viewBounds = [self.iconView bounds];
	CAEmitterLayer *centerSmoke = [CAEmitterLayer layer];
    CAEmitterLayer *bottomLSmoke = [CAEmitterLayer layer];
    CAEmitterLayer *bottomRSmoke = [CAEmitterLayer layer];
    CAEmitterLayer *topRSmoke = [CAEmitterLayer layer];
    CAEmitterLayer *topLSmoke = [CAEmitterLayer layer];
    centerSmoke.emitterPosition = CGPointMake(viewBounds.size.width/2.0, viewBounds.size.height/2.0);
    centerSmoke.emitterMode = kCAEmitterLayerOutline;
    centerSmoke.renderMode = kCAEmitterLayerAdditive;
    centerSmoke.emitterShape = kCAEmitterLayerPoint;
    
    bottomLSmoke.emitterPosition = CGPointMake(5, viewBounds.size.height - 5);
    bottomLSmoke.emitterMode = kCAEmitterLayerOutline;
    bottomLSmoke.renderMode = kCAEmitterLayerAdditive;
    bottomLSmoke.emitterShape = kCAEmitterLayerPoint;
    
    bottomRSmoke.emitterPosition = CGPointMake(viewBounds.size.width - 5, viewBounds.size.height - 5);
    bottomRSmoke.emitterMode = kCAEmitterLayerOutline;
    bottomRSmoke.renderMode = kCAEmitterLayerAdditive;
    bottomRSmoke.emitterShape = kCAEmitterLayerPoint;
    
    topRSmoke.emitterPosition = CGPointMake(viewBounds.size.width - 5, 5);
    topRSmoke.emitterMode = kCAEmitterLayerOutline;
    topRSmoke.renderMode = kCAEmitterLayerAdditive;
    topRSmoke.emitterShape = kCAEmitterLayerPoint;
    
    topLSmoke.emitterPosition = CGPointMake(5, 5);
    topLSmoke.emitterMode = kCAEmitterLayerOutline;
    topLSmoke.renderMode = kCAEmitterLayerAdditive;
    topLSmoke.emitterShape = kCAEmitterLayerPoint;
    
    SmokeCell *bottomLCell = [[SmokeCell alloc] init];
    [bottomLCell setAngle:-M_PI_4];
    [bottomLCell setVelocityRanges:.5];
    [bottomLCell setContentPic:2];
    [bottomLCell setBirthRate:.8];
    [bottomLCell setLifetime:.7];
    bottomLSmoke.emitterCells = [NSArray arrayWithObject:bottomLCell];
    
    SmokeCell *bottomRCell = [[SmokeCell alloc] init];
    [bottomRCell setAngle:5*M_PI_4];
    [bottomRCell setVelocityRanges:3];
    [bottomRCell setContentPic:2];
    [bottomRCell setBirthRate:.7];
    [bottomRCell setLifetime:.7];
    bottomRSmoke.emitterCells = [NSArray arrayWithObject:bottomRCell];
    
    SmokeCell *topRCell = [[SmokeCell alloc]init];
    [topRCell setAngle:3*M_PI_4];
    [topRCell setVelocityRanges:.1];
    [topRCell setContentPic:2];
    [topRCell setBirthRate:1.0];
    [topRCell setLifetime:.7];
    topRSmoke.emitterCells = [NSArray arrayWithObject:topRCell];
    
    SmokeCell *topLCell = [[SmokeCell alloc]init];
    [topLCell setAngle:M_PI_4];
    [topLCell setVelocityRanges:1];
    [topLCell setContentPic:2];
    [topLCell setBirthRate:.5];
    [topLCell setLifetime:.7];
    topLSmoke.emitterCells = [NSArray arrayWithObject:topLCell];
    
    CAEmitterCell* smoke = [CAEmitterCell emitterCell];
    [smoke setName:@"smoke"];
    
    smoke.birthRate = 4;
    smoke.emissionLongitude = 0;
    smoke.velocity = 2;
    smoke.velocityRange = .5;
    smoke.emissionRange = 2 * M_PI;
    smoke.scaleSpeed = 0.1;
    smoke.lifetime = 1;
    smoke.lifetimeRange = .5;
    
    smoke.color = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2] CGColor];
    smoke.contents = (id) [[UIImage imageNamed:@"Sprite2"] CGImage];
    
    centerSmoke.emitterCells = [NSArray arrayWithObject:smoke];
    [self.iconView.layer addSublayer:centerSmoke];
    [self.iconView.layer addSublayer:topLSmoke];
    [self.iconView.layer addSublayer:topRSmoke];
    [self.iconView.layer addSublayer:bottomLSmoke];
    [self.iconView.layer addSublayer:bottomRSmoke];

}

- (void)viewDidAppear:(BOOL)animated {
    if (first) {
        [self setMap];
    }
    //[self performSelector:@selector(updateMapZoomLocation) withObject:nil afterDelay:2.0];
}

- (void)setMap {
    first = NO;
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            [[FenceMonitor getMonitor] removeFences];
            currentPoint = geoPoint;
            userCoord.latitude = currentPoint.latitude;
            userCoord.longitude = currentPoint.longitude;
            [self performSelector:@selector(updateMapZoomLocation) withObject:nil afterDelay:2.0];
            PFQuery *eventQueryPublic = [PFQuery queryWithClassName:@"Event"];
            [eventQueryPublic whereKey:@"Public" equalTo:@1];
            
            PFQuery *eventQueryPrivate = [PFQuery queryWithClassName:@"Event"];
            [eventQueryPrivate whereKey:@"Invited" equalTo:[[PFUser currentUser] objectForKey:@"FacebookID"]];
            
            PFQuery *eventQueryHost = [PFQuery queryWithClassName:@"Event"];
            [eventQueryHost whereKey:@"HostID" equalTo:[[PFUser currentUser] objectForKey:@"FacebookID"]];
            
            PFQuery *eventQuery = [PFQuery orQueryWithSubqueries:@[eventQueryPrivate,eventQueryPublic,eventQueryHost]];
            [eventQuery whereKey:@"Location" nearGeoPoint:currentPoint];
            eventQuery.limit = 10;
            [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                events = [NSMutableArray arrayWithArray:objects];
                for (PFObject *event in events) {
                    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                    CLLocationCoordinate2D coord;
                    coord.latitude = ((PFGeoPoint*)[event objectForKey:@"Location"]).latitude;
                    coord.longitude = ((PFGeoPoint*)[event objectForKey:@"Location"]).longitude;
                    point.coordinate = coord;
                    point.title = [event objectForKey:@"EventName"];
                    point.subtitle = [NSString stringWithFormat:@"Rating: %.2f",[[event objectForKey:@"Rating"] floatValue]];
                    [self.mapView addAnnotation:point];
                    if ([[FenceMonitor getMonitor] checkLocationManager]) {
                        CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:coord radius:150 identifier:[NSString stringWithFormat:@"%f%f",coord.latitude,coord.longitude]];
                        [[FenceMonitor getMonitor] addFence:region andEvent:event];
                    }
                }
                [[FenceMonitor getMonitor] updateFences];
                timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                 target:[FenceMonitor getMonitor]
                                               selector:@selector(updateFences)
                                               userInfo:nil
                                                repeats:YES];
            }];
        }
    }];
}

- (void)updateMapZoomLocation
{
    MKCoordinateRegion region;
    region.center.latitude = userCoord.latitude;
    region.center.longitude = userCoord.longitude;
    region.span.latitudeDelta = 0.05;
    region.span.longitudeDelta = 0.05;
    [self.mapView setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didChangeTab:(id)sender {
    if (self.tabBar.selectedSegmentIndex == 0) {
        self.mapView.hidden = NO;
        self.eventContainer.hidden = YES;
        self.currentView.hidden = YES;
    } else if (self.tabBar.selectedSegmentIndex == 1) {
        self.mapView.hidden = YES;
        self.eventContainer.hidden = NO;
        self.currentView.hidden = YES;
    } else {
        self.mapView.hidden = YES;
        self.eventContainer.hidden = YES;
        self.currentView.hidden = NO;
        self.submitRatingButton.hidden = NO;
        PFObject *event = [[FenceMonitor getMonitor] getCurrentEvent];
        if (event) {
            self.currentEventLabel.text = [[[FenceMonitor getMonitor] getCurrentEvent] objectForKey:@"EventName"];
            self.currentEventDescription.text = [[[FenceMonitor getMonitor] getCurrentEvent] objectForKey:@"Description"];
            self.currentEventDescription.hidden = NO;
            self.ratingSlider.hidden = NO;
            self.submitRatingButton.hidden = NO;
            self.reviewField.hidden = NO;
            self.submitReviewButton.hidden = NO;
        } else {
            self.currentEventLabel.text = @"You're not at an event!";
            self.currentEventDescription.hidden = YES;
            self.ratingSlider.hidden = YES;
            self.submitRatingButton.hidden = YES;
            self.reviewField.hidden = YES;
            self.submitReviewButton.hidden = YES;
        }
    }
}
- (IBAction)onLogout:(id)sender {
    [[FenceMonitor getMonitor] removeFences];
    [timer invalidate];
    timer = nil;
    [PFUser logOut];
    [self performSegueWithIdentifier:@"fromFeedToLoginSegue" sender:self];
}

- (IBAction)onCreate:(id)sender {
    [self performSegueWithIdentifier:@"fromFeedToCreateSegue" sender:self];
}
- (IBAction)onSubmitRating:(id)sender {
    PFObject *event = [[FenceMonitor getMonitor] getCurrentEvent];
    self.submitRatingButton.hidden = YES;
    float n = [[event objectForKey:@"Rating"] floatValue];
    n *= [[event objectForKey:@"RatingCount"] floatValue];
    n += self.ratingSlider.value;
    [event incrementKey:@"RatingCount"];
    n /= [[event objectForKey:@"RatingCount"] intValue];
    [event setObject:[NSNumber numberWithFloat:n] forKey:@"Rating"];
    [event saveInBackground];
}
- (IBAction)onSubmitReview:(id)sender {
    if ([self.reviewField.text length] > 0) {
        self.submitReviewButton.hidden = YES;
        PFObject *event = [[FenceMonitor getMonitor] getCurrentEvent];
        NSMutableArray *reviews = [event objectForKey:@"Reviews"];
        [reviews addObject:[NSString stringWithFormat:@"%@ -%@",self.reviewField.text,[[PFUser currentUser] objectForKey:@"FacebookName"]]];
        [event setObject:reviews forKey:@"Reviews"];
        self.reviewField.text = @"";
        [event saveInBackground];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UIView *view in self.view.subviews) {
        for (UIView *sView in view.subviews) {
            [sView resignFirstResponder];
        }
        [view resignFirstResponder];
    }
}
@end
