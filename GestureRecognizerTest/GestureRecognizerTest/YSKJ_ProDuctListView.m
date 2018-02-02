//
//  YSKJ_ProDuctListView.m
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/10/12.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "YSKJ_ProDuctListView.h"

#import "YSKJ_ProCollectionViewCell.h"

#import "HttpRequestCalss.h"

#import <MJRefresh/MJRefresh.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import <MJExtension/MJExtension.h>

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器
#define SHOPLISTURL  @"http://"API_DOMAIN@"/store/list"    //列表

@implementation YSKJ_ProDuctListView

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake((self.frame.size.width-40)/3, (self.frame.size.width-40)/3);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 70, self.frame.size.width, self.frame.size.height/3*2 - 70) collectionViewLayout:layout];
        _collectionView.backgroundColor=[UIColor grayColor];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        [_collectionView registerClass:[YSKJ_ProCollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
        [self addSubview:_collectionView];
        
        //下拉刷新
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(mj_header)];
        
        UIButton *cancle = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 60, 30)];
        [cancle addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        cancle.backgroundColor = [UIColor redColor];
        [cancle setTitle:@"关闭" forState:UIControlStateNormal];
        [self addSubview:cancle];

        
    }
    return self;
}

static bool ishttpData=NO;         //是否还继续预加载
static bool ishttpagain=NO;        //等上一页加载完再进行下一页

static NSString *page=@"1";

-(void)setShow:(BOOL)show
{
    _show = show;
    
    if (show == YES) {
        
        self.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.frame = CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height);
            
        }];
    }
    
    [self shopHttpData];

}

-(void)setSupView:(UIView *)supView
{
    _supView = supView;
}

-(void)shopHttpData
{
    //状态栏网络监控提示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *paramdict=@{
                              @"cateid":@"1",
                              @"page":page,
                              @"order":@"view_amount",
                              @"ordername":@"desc",
                              @"keyword":@"",
                              @"style":@"",
                              @"space":@"",
                              @"category":@"",
                              @"source":@"",
                              @"pagenum":@"20",
                              @"userid":@"94"
                              };
    
    HttpRequestCalss *httpRequest=[[HttpRequestCalss alloc] init];
    
    [httpRequest postHttpDataWithParam:paramdict url:SHOPLISTURL success:^(NSDictionary *dict, BOOL success) {
        
        ishttpagain=YES;    //是否继续预加载
        NSMutableArray *lineArr=[dict objectForKey:@"data"];
        
        if (lineArr.count<20) {
            ishttpData=NO;
        }else{
            ishttpData=YES;
        }
        
        if ([page isEqualToString:@"1"]) {
            _list=lineArr;
            
        }else{
            [_list addObjectsFromArray:lineArr];
        }
        
        [_collectionView reloadData];
        [_collectionView.mj_header endRefreshing];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } fail:^(NSError *error) {
    
        [_collectionView.mj_header endRefreshing];
        
    }];
}

#pragma mark 下拉刷新
static int intPage =1;
-(void)mj_header
{
    page=@"1";
    intPage=1;
    [self shopHttpData];
}

-(void)cancleAction
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.frame = CGRectMake(self.frame.size.width*3, 0, self.frame.size.width, self.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        self.hidden = YES;
        
    }];
}


#pragma mark UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _list.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    YSKJ_ProCollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    NSDictionary *obj = _list[indexPath.row];
    
    cell.url = [obj objectForKey:@"thumb_file"];
    
    [cell.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (_list.count-indexPath.row<4) {
        if (ishttpagain==YES) {
            if (ishttpData==YES) {
                intPage++;
                page=[NSString stringWithFormat:@"%d",intPage];
                [self shopHttpData];
            }
            ishttpagain=NO;
        }
        
    }
    
    return cell;
    
}

//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {0,10,0,10};
    return top;
}

-(void)buttonAction:(UIButton*)sender
{
    UICollectionViewCell *tableViewCell = (UICollectionViewCell*)[sender superview];
    NSIndexPath *indexPath = [_collectionView indexPathForCell:tableViewCell];
    NSDictionary *obj = _list[indexPath.row];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    
    //获取网络图片的Size
    [imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@",[obj objectForKey:@"thumb_file"]]] placeholderImage:nil options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        if (image.size.width>0 && image.size.height>0) {
            
            float centerX = self.supView.center.x;
            float centerY = self.supView.center.y;
            float x=centerX-(image.size.width*0.3)/2 - 60;
            float y=centerY-(image.size.height*0.3)/2 - 60;
            [jsonDict setObject:[NSString stringWithFormat:@"%f",centerX] forKey:@"centerX"];
            [jsonDict setObject:[NSString stringWithFormat:@"%f",centerY] forKey:@"centerY"];
            [jsonDict setObject:[NSString stringWithFormat:@"%f",x] forKey:@"x"];
            [jsonDict setObject:[NSString stringWithFormat:@"%f",y] forKey:@"y"];
            [jsonDict setObject:[NSString stringWithFormat:@"%f",image.size.width*0.3] forKey:@"w"];
            [jsonDict setObject:[NSString stringWithFormat:@"%f",image.size.height*0.3] forKey:@"h"];
            [jsonDict setObject:@"0" forKey:@"angle"];
            [jsonDict setObject:@"1000" forKey:@"tag"];   //默认1000，当添加是根据画板的个数进行修改
            [jsonDict setObject:@"0" forKey:@"lockState"];
            [jsonDict setObject:@"0" forKey:@"mirror"];
            [jsonDict setObject:[obj objectForKey:@"thumb_file"] forKey:@"url"];
            
            NSMutableArray *controlePointArr = [[NSMutableArray alloc] init];
            NSDictionary *ltPoint = @{
                                      @"centerX":[NSString stringWithFormat:@"%f",x],
                                      @"centerY":[NSString stringWithFormat:@"%f",y]
                                      };
            NSDictionary *rtPoint = @{
                                      @"centerX":[NSString stringWithFormat:@"%f",x+image.size.width*0.3],
                                      @"centerY":[NSString stringWithFormat:@"%f",y]
                                      };
            NSDictionary *lbPoint = @{
                                      @"centerX":[NSString stringWithFormat:@"%f",x],
                                      @"centerY":[NSString stringWithFormat:@"%f",y+image.size.height*0.3]
                                      };
            NSDictionary *rbPoint = @{
                                      @"centerX":[NSString stringWithFormat:@"%f",x+image.size.width*0.3],
                                      @"centerY":[NSString stringWithFormat:@"%f",y+image.size.height*0.3]
                                      };
            [controlePointArr addObject:ltPoint];
            [controlePointArr addObject:rtPoint];
            [controlePointArr addObject:lbPoint];
            [controlePointArr addObject:rbPoint];
            
            [jsonDict setObject:controlePointArr forKey:@"contorlPoint"];
            
        }
  
    }];
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(addProToDrawBoard:)] && [jsonDict allKeys].count!=0) {
        
        YSKJ_drawModel *model = [YSKJ_drawModel mj_objectWithKeyValues:jsonDict];
        
        [self.delegate addProToDrawBoard:model];
    }
    
}


@end
