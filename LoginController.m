//
//  LoginController.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "LoginController.h"
#import <Parse/Parse.h>
#import "SmokeCell.h"

@interface LoginController ()
@property (strong, nonatomic) IBOutlet UIView *iconView;
- (IBAction)onLogin:(id)sender;

@end

@implementation LoginController

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
    
    bottomLSmoke.emitterPosition = CGPointMake(155 - .7 * 155, 155 + .7 * 155);
    bottomLSmoke.emitterMode = kCAEmitterLayerOutline;
    bottomLSmoke.renderMode = kCAEmitterLayerAdditive;
    bottomLSmoke.emitterShape = kCAEmitterLayerPoint;
    
    bottomRSmoke.emitterPosition = CGPointMake(155 + .7 * 155, 155 + .7 * 155);
    bottomRSmoke.emitterMode = kCAEmitterLayerOutline;
    bottomRSmoke.renderMode = kCAEmitterLayerAdditive;
    bottomRSmoke.emitterShape = kCAEmitterLayerPoint;
    
    topRSmoke.emitterPosition = CGPointMake(155 + .7 * 155, 155 - .7 * 155);
    topRSmoke.emitterMode = kCAEmitterLayerOutline;
    topRSmoke.renderMode = kCAEmitterLayerAdditive;
    topRSmoke.emitterShape = kCAEmitterLayerPoint;
    
    topLSmoke.emitterPosition = CGPointMake(155 - .7 * 155, 155 - .7 * 155);
    topLSmoke.emitterMode = kCAEmitterLayerOutline;
    topLSmoke.renderMode = kCAEmitterLayerAdditive;
    topLSmoke.emitterShape = kCAEmitterLayerPoint;
    
    SmokeCell *bottomLCell = [[SmokeCell alloc] init];
    [bottomLCell setAngle:-M_PI_4];
    [bottomLCell setVelocityRanges:4];
    bottomLSmoke.emitterCells = [NSArray arrayWithObject:bottomLCell];
    
    SmokeCell *bottomRCell = [[SmokeCell alloc] init];
    [bottomRCell setAngle:5*M_PI_4];
    [bottomRCell setVelocityRanges:15];
    bottomRSmoke.emitterCells = [NSArray arrayWithObject:bottomRCell];
    
    SmokeCell *topRCell = [[SmokeCell alloc]init];
    [topRCell setAngle:3*M_PI_4];
    [topRCell setVelocityRanges:8];
    topRSmoke.emitterCells = [NSArray arrayWithObject:topRCell];
    
    SmokeCell *topLCell = [[SmokeCell alloc]init];
    [topLCell setAngle:M_PI_4];
    [topLCell setVelocityRanges:30];
    topLSmoke.emitterCells = [NSArray arrayWithObject:topLCell];
    
    CAEmitterCell* smoke = [CAEmitterCell emitterCell];
    [smoke setName:@"smoke"];
    
    smoke.birthRate = 20;
    smoke.emissionLongitude = 0;
    smoke.velocity = 20;
    smoke.velocityRange = 5;
    smoke.emissionRange = 2 * M_PI;
    smoke.scaleSpeed = 0.3;
    smoke.lifetime = 1.5;
    smoke.lifetimeRange = .1;
    
    smoke.color = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1] CGColor];
    smoke.contents = (id) [[UIImage imageNamed:@"Sprite"] CGImage];
    
    centerSmoke.emitterCells = [NSArray arrayWithObject:smoke];
    [self.iconView.layer addSublayer:centerSmoke];
    [self.iconView.layer addSublayer:bottomLSmoke];
    [self.iconView.layer addSublayer:bottomRSmoke];
    [self.iconView.layer addSublayer:topLSmoke];
    [self.iconView.layer addSublayer:topRSmoke];
    
}

- (void)viewDidAppear:(BOOL)animated {
    if(![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh oh!" message:@"You need location services turned on to use this app!" delegate:self cancelButtonTitle:Nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    if ([PFUser currentUser] && // Check if a user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) // Check if user is linked to Facebook
    {
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result will contain an array with your user's friends in the "data" key
                NSArray *friendObjects = [result objectForKey:@"data"];
                NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                // Create a list of friends' Facebook IDs
                for (NSDictionary *friendObject in friendObjects) {
                    [friendIds addObject:[friendObject objectForKey:@"id"]];
                }
                [[PFUser currentUser] setObject:friendIds forKey:@"Friends"];
                
                [[PFUser currentUser] saveInBackground];
            }
        }];
        [self performSegueWithIdentifier:@"fromLoginToFeedSegue" sender:self];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogin:(id)sender {
    if(![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh oh!" message:@"You need location services turned on to use this app!" delegate:self cancelButtonTitle:Nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    NSArray *permissionsArray = @[];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else {
            NSLog(@"User with facebook signed up and logged in!");
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSString *facebookID = [result objectForKey:@"id"];
                NSString *facebookName = [result objectForKey:@"name"];
                
                if (facebookName && facebookName != 0) {
                    [user setObject:facebookName forKey:@"FacebookName"];
                }
                if (facebookID && facebookID != 0) {
                    [user setObject:facebookID forKey:@"FacebookID"];
                }
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            NSArray *data = [result objectForKey:@"data"];
                            NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:data.count];
                            for (NSDictionary *friendData in data) {
                                [facebookIds addObject:[friendData objectForKey:@"id"]];
                            }
                            [user setObject:facebookIds forKey:@"Friends"];
                            [user saveInBackground];
                        } else {
                            NSLog(@"error");
                        }
                    }];
                }];
            }];
            [self performSegueWithIdentifier:@"fromLoginToFeedSegue" sender:self];
        }
    }];
}
@end
