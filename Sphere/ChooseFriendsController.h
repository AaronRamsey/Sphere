//
//  ChooseFriendsController.h
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseFriendsController : UITableViewController
@property (strong,nonatomic) NSMutableArray *friends;
-(NSMutableArray*)getCells;
@end
