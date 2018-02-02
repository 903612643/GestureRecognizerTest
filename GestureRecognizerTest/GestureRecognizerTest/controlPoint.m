//
//  controlPoint.m
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/10/10.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "controlPoint.h"

@implementation controlPoint

-(id)initWithFrame:(CGRect)frame{
    
    if (self==[super initWithFrame:frame]) {
        
        [self setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
        
        self.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
        
    }
    
    return self;
}

@end
