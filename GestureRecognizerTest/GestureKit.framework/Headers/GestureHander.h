//
//  GestureHander.h
//  GestureKit
//
//  Created by YSKJ on 18/1/30.
//  Copyright © 2018年 com.yskj. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@class GestureConfiguration;

@interface GestureHander : NSObject
{
    GestureConfiguration *_gesCnf;
    
    UIView *_targetView;
    
    NSDictionary *_objDict;
}

-(instancetype)initWithView:(UIView*)targetView objDict:(NSDictionary*)objDict configuration:(GestureConfiguration*)gesCnf;

-(void)drawRectView;

@end
