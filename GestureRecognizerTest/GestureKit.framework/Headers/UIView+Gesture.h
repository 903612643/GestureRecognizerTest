//
//  UIView+Gesture.h
//  GestureKit
//
//  Created by YSKJ on 18/1/30.
//  Copyright © 2018年 com.yskj. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "GestureHander.h"

#import "GestureConfiguration.h"

@interface UIView (Gesture)

-(void)G_showGesture:(GestureConfiguration*)cnf objDict:(NSDictionary*)objDict;


@end
