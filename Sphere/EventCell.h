//
//  EventCell.h
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *eventLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *yellowImage;
@end
