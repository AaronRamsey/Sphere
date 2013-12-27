//
//  ReviewsController.m
//  Sphere
//
//  Created by Alex Koren on 12/1/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "ReviewsController.h"
#import "REviewCell.h"
@interface ReviewsController ()

@end

@implementation ReviewsController{

}
@synthesize reviews;

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
    [self reloadTable];
}

- (void)reloadTable {
    [self.tableView reloadData];
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
    return [reviews count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReviewCell";
    
    ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReviewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.reviewLabel.text = [reviews objectAtIndex:indexPath.row];
    return cell;
}

@end
