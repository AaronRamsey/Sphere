//
//  CreateEventController.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "CreateEventController.h"
#import <MapKit/MapKit.h>
#import "AnnotationView.h"
#import <CoreLocation/CoreLocation.h>
#import "ChooseFriendsController.h"
#import <Parse/Parse.h>
#import "ChooseFriendCell.h"

@interface CreateEventController ()
@property (strong, nonatomic) IBOutlet UITextField *eventNameField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionField;
- (IBAction)onChooseFriends:(id)sender;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)onSend:(id)sender;
- (IBAction)onReset:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *chooseContainer;
@property (strong, nonatomic) IBOutlet UIView *chooseView;
- (IBAction)onCancel:(id)sender;
- (IBAction)onBack:(id)sender;

@end

@implementation CreateEventController {
    MKPointAnnotation *dropPin;
    ChooseFriendsController *friendsTable;
    BOOL chosePoint;
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
    //self.chooseView.hidden = YES;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
	// Do any additional setup after loading the view.
}

- (void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    // This is important if you only want to receive one tap and hold event
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self.mapView removeGestureRecognizer:sender];
    }
    else
    {
        // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
        CGPoint point = [sender locationInView:self.mapView];
        CLLocationCoordinate2D locCoord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        // Then all you have to do is create the annotation and add it to the map
        dropPin = [[MKPointAnnotation alloc] init];
        dropPin.coordinate = locCoord;
        [self.mapView addAnnotation:dropPin];
        chosePoint = YES;
        [self.mapView removeGestureRecognizer:sender];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onChooseFriends:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.chooseView.frame = CGRectMake(10,70,300,488);
    [UIView commitAnimations];
    
}
- (IBAction)onSend:(id)sender {
    if (chosePoint) {
        if ([self.eventNameField.text length] > 0 && [self.descriptionField.text length] > 0) {
            NSMutableArray *friendsCells = [friendsTable getCells];
            NSMutableArray *friendsNames = [[NSMutableArray alloc]init];
            for (ChooseFriendCell *cell in friendsCells) {
                if (cell.switchElement.on) {
                    [friendsNames addObject:cell.nameLabel.text];
                }
            }
            [self performSegueWithIdentifier:@"fromCreateToFeedSegue" sender:self];
            if ([friendsNames count] == 0) {
                PFObject *event = [PFObject objectWithClassName:@"Event"];
                [event setObject:@[] forKey:@"Invited"];
                [event setObject:self.eventNameField.text forKey:@"EventName"];
                [event setObject:self.descriptionField.text forKey:@"Description"];
                PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:dropPin.coordinate.latitude longitude:dropPin.coordinate.longitude];
                [event setObject:point forKey:@"Location"];
                [event setObject:@5 forKey:@"Rating"];
                [event setObject:@0 forKey:@"RatingCount"];
                [event setObject:@[] forKey:@"Attendees"];
                [event setObject:@[] forKey:@"Reviews"];
                [event setObject:@1 forKey:@"Public"];
                [event setObject:[[PFUser currentUser] objectForKey:@"FacebookID"] forKey:@"HostID"];
                [event saveInBackground];
            } else {
                PFObject *event = [PFObject objectWithClassName:@"Event"];
                [event setObject:friendsNames forKey:@"Invited"];
                [event setObject:self.eventNameField.text forKey:@"EventName"];
                [event setObject:self.descriptionField.text forKey:@"Description"];
                PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:dropPin.coordinate.latitude longitude:dropPin.coordinate.longitude];
                [event setObject:point forKey:@"Location"];
                [event setObject:@5 forKey:@"Rating"];
                [event setObject:@0 forKey:@"RatingCount"];
                [event setObject:@[] forKey:@"Attendees"];
                [event setObject:@[] forKey:@"Reviews"];
                [event setObject:@0 forKey:@"Public"];
                [event setObject:[[PFUser currentUser] objectForKey:@"FacebookID"] forKey:@"HostID"];
                [event saveInBackground];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh oh!" message:@"Make sure you have an event name and description!" delegate:self cancelButtonTitle:Nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh oh!" message:@"You have to choose a point on the map!" delegate:self cancelButtonTitle:Nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chooseFriendsEmbed"]) {
        friendsTable = segue.destinationViewController;
        friendsTable.friends = [[PFUser currentUser] objectForKey:@"Friends"];
    }
}

- (IBAction)onReset:(id)sender {
    if (dropPin) {
        [self.mapView removeAnnotations:@[dropPin]];
        chosePoint = NO;
    }
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UIView *view in self.view.subviews) {
        for (UIView *sView in view.subviews) {
            [sView resignFirstResponder];
        }
        [view resignFirstResponder];
    }
}
- (IBAction)onCancel:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.chooseView.frame = CGRectMake(10,568,300,488);
    [UIView commitAnimations];
}

- (IBAction)onBack:(id)sender {
}
@end
