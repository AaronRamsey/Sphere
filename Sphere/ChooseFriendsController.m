//
//  ChooseFriendsController.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "ChooseFriendsController.h"
#import <Parse/Parse.h>
#import "ChooseFriendCell.h"

@interface ChooseFriendsController ()

@end

@implementation ChooseFriendsController{
    NSMutableArray *cells;
    NSMutableArray *friendsNames;
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
    cells = [[NSMutableArray alloc]init];
    [self reloadTable];
}

- (void)reloadTable {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"FacebookID" containedIn:friends];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        friendsNames = [[NSMutableArray alloc]init];
        for (PFObject *object in objects) {
            [friendsNames addObject:[object objectForKey:@"FacebookName"]];
        }
        [self.tableView reloadData];
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
    return [friendsNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChooseFriendCell";
    
    ChooseFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChooseFriendCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.nameLabel.text = [friendsNames objectAtIndex:indexPath.row];
    cell.switchElement.on = NO;
    [cells addObject:cell];
    return cell;
    
}

- (NSMutableArray*) getCells {
    return cells;
}

@end
