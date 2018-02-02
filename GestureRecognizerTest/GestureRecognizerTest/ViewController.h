//
//  ViewController.h
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/9/30.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GestureKit/GestureKit.h>

@interface ViewController : UIViewController
{
    NSMutableArray *drowCopy;
    
    GestureConfiguration *_gesCnf;
}

@property (nonatomic, strong) UIButton *proBut;

@property (nonatomic, strong) UIButton *LTBut;

@property (nonatomic, strong) UIButton *RTBut;

@property (nonatomic, strong) UIButton *LBBut;

@property (nonatomic, strong) UIButton *RBBut;


@end

