//
//  ViewController.m
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/9/30.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "ViewController.h"

#import "YSKJ_OperationView.h"

#import "HttpRequestCalss.h"

#import <AGGeometryKit/AGGeometryKit.h>

#import <POPAnimatableProperty+AGGeometryKit.h>

#import <pop/POP.h>

#import <SDWebImage/UIButton+WebCache.h>

#import <MJExtension/MJExtension.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import <SDWebImage/UIButton+WebCache.h>

#import "YSKJ_CanvasParamModel.h"

#import "controlPoint.h"

#import "YSKJ_ProDuctListView.h"

#import "YSKJ_drawModel.h"

#import "YSKJ_HistoryModel.h"

#define API_DOMAIN @"www.5164casa.com/api/saas"                  //正式服务器

#define GETPLANLIST @"http://"API_DOMAIN@"/solution/getmylist" //得到方案列表

@interface ViewController ()<UIGestureRecognizerDelegate,YSKJ_OperationViewDelegate,YSKJ_ProDuctListViewDelegate>

{
    UIButton *_button;
    
    NSMutableArray *_productDataArr;
    
    YSKJ_OperationView *_operation;
    
    UIView *o_ltBut,*o_rtBut,*o_lbBut,*o_rbBut;
    
    UIButton *_nextBut,*_backBut;
    
    UIView *_drawBoardView;
    
    YSKJ_ProDuctListView *listView;
    
    NSMutableArray *_historiesArr;
    
}

@end

@implementation ViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    
    _drawBoardView = [[UIView alloc] initWithFrame:CGRectMake(70, 70, self.view.frame.size.width - 140, self.view.frame.size.height - 140)];
    _drawBoardView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    _drawBoardView.layer.cornerRadius = 16;
    _drawBoardView.layer.masksToBounds = YES;
    [self.view addSubview:_drawBoardView];
    
    _operation = [[YSKJ_OperationView alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
    _operation.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    _operation.supView = _drawBoardView;
    _operation.delegate = self;
    [_drawBoardView addSubview:_operation];
    
    _productDataArr = [[NSMutableArray alloc] init];
    
    _historiesArr = [[NSMutableArray alloc] init];
    
    [self addHistoryArr];   //加载空画布到历史纪录
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(40, 30, 60, 30)];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    back.backgroundColor = [UIColor grayColor];
    back.enabled = NO;
    [back setTitle:@"撤销" forState:UIControlStateNormal];
    _backBut = back;
    [self.view addSubview:back];
    
    UIButton *next = [[UIButton alloc] initWithFrame:CGRectMake(120, 30, 60, 30)];
    [next addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    next.backgroundColor = [UIColor grayColor];
    next.enabled = NO;
    [next setTitle:@"前进" forState:UIControlStateNormal];
    _nextBut = next;
    [self.view addSubview:next];
    
    UIButton *add = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100, 30, 60, 30)];
    [add addTarget:self action:@selector(showProductList) forControlEvents:UIControlEventTouchUpInside];
    add.backgroundColor = [UIColor redColor];
    [add setTitle:@"添加" forState:UIControlStateNormal];
    [self.view addSubview:add];
    
    listView = [[YSKJ_ProDuctListView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width/3, self.view.frame.size.height)];
    listView.delegate = self;
    listView.supView = _drawBoardView;
    listView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:listView];
    
    _gesCnf = [[GestureConfiguration alloc] init];
    _gesCnf.g_x = 3000;

}

-(void)showProductList
{
    listView.show = YES;
}

#pragma YSKJ_OperationViewDelegate 

-(void)update
{
    [self addHistoryArr];
}

#pragma mark YSKJ_ProDuctListViewDelegate

-(void)addProToDrawBoard:(YSKJ_drawModel *)model;
{
    UIButton *proBut = [[UIButton alloc] initWithFrame:CGRectMake([model.x floatValue], [model.y floatValue], [model.w floatValue], [model.h floatValue])];
    
    proBut.tag = 1000 + _productDataArr.count*10;
    
    [proBut sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.url]] forState:UIControlStateNormal placeholderImage:nil];
    
    [proBut addTarget:self action:@selector(getProduct:) forControlEvents:UIControlEventTouchUpInside];
    
    [_drawBoardView addSubview:proBut];
    
    model.tag = [NSString stringWithFormat:@"%ld",(long)proBut.tag];
    
    [_productDataArr addObject:model];

    [self setUpControlPoint:model proBut:proBut];
    
    [self getProduct:proBut];
    
    [self addHistoryArr];
  
}

#pragma mark 添加到历史纪录

-(void)addHistoryArr
{
    if (_hisIndex<_historiesArr.count) {
        
        NSMutableArray *tempArray=[[NSMutableArray alloc] init];
        for (int i=0; i<_hisIndex; i++) {
            [tempArray addObject:_historiesArr[i]];
        }
        [_historiesArr removeAllObjects];
        _historiesArr=tempArray;
    }
    
    NSMutableArray *productArr = [[NSMutableArray alloc] init];
    for (YSKJ_drawModel *model in _productDataArr) {
        [productArr addObject:[model copy]];
    }
    
    YSKJ_HistoryModel *hisModel = [[YSKJ_HistoryModel alloc] init];
    
    hisModel.count =  [NSString stringWithFormat:@"%ld",(unsigned long)productArr.count];
    
    hisModel.data = productArr;
    
    [_historiesArr addObject:hisModel];

    _hisIndex=_historiesArr.count;
    
    _backBut.backgroundColor = [UIColor redColor];
    _backBut.enabled = YES;
    
    _nextBut.backgroundColor = [UIColor grayColor];
    _nextBut.enabled = NO;
}

#pragma mark 添加controlePoint 

-(void)setUpControlPoint:(YSKJ_drawModel*)model proBut:(UIButton*)proBut
{
    NSMutableArray *arr = model.contorlPoint;
    
    UIButton *tempTLbutton,*tempTRbutton,*tempBLbutton,*tempBRbutton;
    
    for (int i=0;i<arr.count;i++) {
        
        NSDictionary *contorlPointDict=arr[i];
        
        float ctx=[[contorlPointDict objectForKey:@"centerX"] floatValue];
        float cty=[[contorlPointDict objectForKey:@"centerY"] floatValue];
        
        controlPoint *controlpoint=[[controlPoint alloc] initWithFrame:CGRectMake(ctx-15, cty-15, 30, 30)];
        
        controlpoint.hidden = YES;
        
        controlpoint.tag=proBut.tag+1000+i;
        
        [_drawBoardView addSubview:controlpoint];
        
        i==0?(tempTLbutton=controlpoint):(i==1?(tempTRbutton = controlpoint):(i==2?(tempBLbutton=controlpoint):(tempBRbutton=controlpoint)));
        
        [proBut.layer ensureAnchorPointIsSetToZero];
        
        proBut.layer.quadrilateral = AGKQuadMake(tempTLbutton.center,tempTRbutton.center,tempBRbutton.center,tempBLbutton.center);
        
    }
}

#pragma mark 前进

-(void)nextAction
{
    _operation.hidden = YES;
    
    if (_hisIndex<_historiesArr.count) {
        
        _hisIndex++;
        
        for (UIView *subViews in _drawBoardView.subviews) {
            
            if (subViews!=_operation) {
                [subViews removeFromSuperview];
                
            }
        }
        
        YSKJ_HistoryModel *hisModel = _historiesArr[_hisIndex-1];
        [self setUpOpenPlanView:hisModel.data];
        
    }
    
    if (_hisIndex==_historiesArr.count) {

        _nextBut.backgroundColor = [UIColor grayColor];
        _nextBut.enabled = NO;
    }
    
    _backBut.backgroundColor = [UIColor redColor];
    _backBut.enabled = YES;
    
}

#pragma mark 后退

-(void)backAction
{
    _operation.hidden = YES;
    
    if (_historiesArr.count>1) {
        
        _hisIndex--;
        
        for (UIView *subViews in _drawBoardView.subviews) {
            
            if (subViews!=_operation) {
                [subViews removeFromSuperview];
            }
        }
        YSKJ_HistoryModel *hisModel = _historiesArr[_hisIndex-1];
        [self setUpOpenPlanView:hisModel.data];
    }
    
    if (_hisIndex==1) {
        
        _backBut.backgroundColor = [UIColor grayColor];
        _backBut.enabled = NO;
        
    }
    
    _nextBut.backgroundColor = [UIColor redColor];
    _nextBut.enabled = YES;
    
}

#pragma mark  openPlan －－－－－－－－－－－－－打开方案

-(void)setUpOpenPlanView:(NSArray *)data
{
    [_productDataArr removeAllObjects];
    
    for (int i=0;i<data.count;i++) {
  
        YSKJ_drawModel *model = data[i];
        
        UIButton *product = [[UIButton alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
        
        [product sd_setImageWithURL:[[NSURL alloc] initWithString:model.url] forState:UIControlStateNormal];
        
        [product addTarget:self action:@selector(getProduct:) forControlEvents:UIControlEventTouchDown];
        
        product.tag = 1000+10*i;
        
        model.tag = [NSString stringWithFormat:@"%ld",(long)product.tag];
        
        [_drawBoardView addSubview:product];
        
        [self setUpControlPoint:model proBut:product];
    
        [product G_showGesture:_gesCnf objDict:@{@"id":@"111111"}];
      
    
    }
    
    _productDataArr = [[NSMutableArray alloc] init];
    for (YSKJ_drawModel *model in data) {
        [_productDataArr addObject:[model copy]];
    }
}

static NSInteger _hisIndex = 0;

-(void)getProduct:(UIButton*)sender
{
    for (YSKJ_drawModel *model in _productDataArr) {
        
        if ([model.tag integerValue] == sender.tag) {
            
            _operation.hidden = NO;
            
            _operation.proBut = sender;
            
            _operation.model = model;
            
            _LTBut.hidden = YES; _RTBut.hidden = YES; _LBBut.hidden = YES; _RBBut.hidden = YES;
            
            _LTBut = [self.view viewWithTag:sender.tag+1000];
            
            _RTBut = [self.view viewWithTag:sender.tag+1001];
            
            _LBBut = [self.view viewWithTag:sender.tag+1002];
            
            _RBBut = [self.view viewWithTag:sender.tag+1003];
            
            _LTBut.hidden = NO; _RTBut.hidden = NO; _LBBut.hidden = NO; _RBBut.hidden = NO;
            
            [_operation.superview bringSubviewToFront:_operation];

        }
    }
    
    CGRect letfTopRect = [_LTBut.superview convertRect:_LTBut.frame toView:_operation];
    CGRect rightTopRect = [_RTBut.superview convertRect:_RTBut.frame toView:_operation];
    CGRect letfbottomRect = [_LBBut.superview convertRect:_LBBut.frame toView:_operation];
    CGRect rightBottomRect = [_RBBut.superview convertRect:_RBBut.frame toView:_operation];
    
    _operation.ltRect = letfTopRect;
    _operation.rtRect = rightTopRect;
    _operation.lbRect = letfbottomRect;
    _operation.rbRect = rightBottomRect;
    
}

#pragma mark UIGestureRecognizerDelegate
//和其他手势一起进行
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
