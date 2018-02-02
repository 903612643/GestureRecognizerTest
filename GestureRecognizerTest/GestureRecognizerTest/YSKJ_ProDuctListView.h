//
//  YSKJ_ProDuctListView.h
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/10/12.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YSKJ_drawModel.h"

@protocol YSKJ_ProDuctListViewDelegate <NSObject>

@optional

-(void)addProToDrawBoard:(YSKJ_drawModel*)model;

@end

@interface YSKJ_ProDuctListView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *_list;
}

@property (nonatomic ,assign) BOOL show;

@property (nonatomic, strong) UIView *supView;

@property (nonatomic, retain) id<YSKJ_ProDuctListViewDelegate>delegate;

@end
