//
//  SmokeCell.m
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import "SmokeCell.h"

@implementation SmokeCell

- (id)init
{
    self = [super init];
    if (self) {
        self.birthRate = .8;
        self.velocity = 30;
        self.velocityRange = 10;
        self.emissionRange = 0;
        self.scaleSpeed = .3;
        self.lifetime = 5;
        self.lifetimeRange = 1;
        self.color = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] CGColor];
        self.contents = (id) [[UIImage imageNamed:@"Sprite"] CGImage];
    }
    return self;
}

- (void)setAngle:(float)angle {
    self.emissionLongitude = angle;
}

- (void)setVelocityRanges:(float)range {
    self.velocityRange = range;
}

- (void)setContentPic:(int)val {
    if (val == 1) {
        self.contents = (id) [[UIImage imageNamed:@"Sprite"] CGImage];
    } else {
        self.contents = (id) [[UIImage imageNamed:@"Sprite2"] CGImage];
    }
}

@end
