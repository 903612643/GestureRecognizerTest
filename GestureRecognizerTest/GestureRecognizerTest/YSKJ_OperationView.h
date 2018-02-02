//
//  YSKJ_OperationImageView.h
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/9/30.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YSKJ_drawModel.h"

@protocol YSKJ_OperationViewDelegate <NSObject>

@optional

-(void)update;

@end

@interface YSKJ_OperationView : UIView<UIGestureRecognizerDelegate>
{
    UIView *_ltView,*_rtView,*_lbView,*_rbView;

}

@property (nonatomic, retain)id<YSKJ_OperationViewDelegate> delegate;

@property (nonatomic, strong) UIView *supView;

@property (nonatomic, strong) UIButton *proBut;

@property (nonatomic, assign) CGRect ltRect;

@property (nonatomic, assign) CGRect rtRect;

@property (nonatomic, assign) CGRect lbRect;

@property (nonatomic, assign) CGRect rbRect;

@property (nonatomic, retain) YSKJ_drawModel *model;


@end
