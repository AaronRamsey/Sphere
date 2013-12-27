//
//  FriendsAtEventController.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "FriendsAtEventController.h"
#import "FriendAtEventCell.h"
#import <Parse/Parse.h>

@interface FriendsAtEventController ()

@end

@implementation FriendsAtEventController {
    NSMutableArray *shownFriends;
}
@synthesize friends;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    shownFriends = [[NSMutableArray alloc] init];
    [self reloadTable];
}

- (void)reloadTable {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"FacebookName" containedIn:friends];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *userIDs = [[NSMutableArray alloc]init];
        for (PFObject *user in objects) {
            [userIDs addObject:[user objectForKey:@"FacebookID"]];
        }
        PFQuery *friendQuery = [PFUser query];
        [friendQuery whereKey:@"FacebookID" containedIn:userIDs];
        [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *friend in objects) {
                [shownFriends addObject:[friend objectForKey:@"FacebookName"]];
            }
            [self.tableView reloadData];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [shownFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendAtEventCell";
    
    FriendAtEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendAtEventCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.nameLabel.text = [shownFriends objectAtIndex:indexPath.row];
    return cell;
}

@end