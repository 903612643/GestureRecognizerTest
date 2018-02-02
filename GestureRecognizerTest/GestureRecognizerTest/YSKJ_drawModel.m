//
//  YSKJ_drawModel.m
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/10/13.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "YSKJ_drawModel.h"

@implementation YSKJ_drawModel

-(id)copyWithZone:(NSZone *)zone {

    YSKJ_drawModel *newClass = [[YSKJ_drawModel alloc]init];
    newClass.x = self.x;
    newClass.y = self.y;
    newClass.w = self.w;
    newClass.h = self.h;
    newClass.centerX = self.centerX;
    newClass.centerY = self.centerY;
    newClass.url = self.url;
    newClass.tag = self.tag;
    newClass.mirror = self.mirror;
    newClass.angle = self.angle;
    newClass.lockState = self.lockState;
    newClass.contorlPoint = self.contorlPoint;
    return newClass;
    
}

@end
