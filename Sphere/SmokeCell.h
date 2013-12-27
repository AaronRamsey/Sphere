//
//  SmokeCell.h
//  Sphere
//
//  Created by Alex Koren on 11/30/13.
//  Copyright (c) 2013 AKApps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SmokeCell : CAEmitterCell
-(void)setAngle:(float)angle;
-(void)setVelocityRanges:(float)range;
-(void)setContentPic:(int)val;
@end
