//
//  YSKJ_OperationImageView.m
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/9/30.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "YSKJ_OperationView.h"

#import <AGGeometryKit/AGGeometryKit.h>

#import <POPAnimatableProperty+AGGeometryKit.h>

#import <pop/POP.h>

@implementation YSKJ_OperationView

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        [self createPinchGesture];
        
        [self createRotataeGesture];
        
        [self createPanGesture];
        
        [self createDoubleGesture];
        
        for (int i=0; i<4; i++) {
            
            UIView *ctView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
          //  [self addSubview:ctView];
            //控制点映射到self的点
            i==0?(_ltView=ctView):(i==1?(_rtView=ctView):(i==2?(_lbView=ctView):(_rbView=ctView)));
            
        }
    }
    
    return self;
}
static float w=1;
-(void)setLtRect:(CGRect)ltRect
{
    _ltView.frame = CGRectMake(ltRect.origin.x + (ltRect.size.width-w)/2, ltRect.origin.y + (ltRect.size.height-w)/2, w, w);
}

-(void)setRtRect:(CGRect)rtRect
{
    _rtView.frame = CGRectMake(rtRect.origin.x+(rtRect.size.width-w)/2, rtRect.origin.y+ (rtRect.size.height-w)/2, w, w);
}

-(void)setLbRect:(CGRect)lbRect
{
    _lbView.frame = CGRectMake(lbRect.origin.x+(lbRect.size.width-w)/2, lbRect.origin.y+ (lbRect.size.height-w)/2, w, w);
}

-(void)setRbRect:(CGRect)rbRect
{
     _rbView.frame = CGRectMake(rbRect.origin.x+(rbRect.size.width-w)/2, rbRect.origin.y+ (rbRect.size.height-w)/2, w, w);
}

-(void)setModel:(YSKJ_drawModel *)model
{
    _model = model;
    
    float angle = [model.angle  floatValue];
    
    self.transform = CGAffineTransformMakeRotation(0);
    
    self.frame=CGRectMake([model.x floatValue], [model.y floatValue], [model.w floatValue], [model.h floatValue]);
    
    self.transform = CGAffineTransformMakeRotation(angle);
    
}

#pragma mark 添加手势

//创建缩放手势
-(void)createPinchGesture
{
    UIPinchGestureRecognizer *pinchGes  =[[UIPinchGestureRecognizer alloc]init];
    
    pinchGes .delegate = self;
    
    [pinchGes addTarget:self action:@selector(pinchGes:)];
    
    [self addGestureRecognizer:pinchGes];
    
}

//创建旋转手势
-(void)createRotataeGesture
{
    UIRotationGestureRecognizer *rotationGes = [[UIRotationGestureRecognizer alloc]init];
    
    rotationGes.delegate = self;
    
    [rotationGes addTarget:self action:@selector(rotGes:)];
    
    [self addGestureRecognizer:rotationGes];
    
}

//创建拖动手势
-(void)createPanGesture

{
    UIPanGestureRecognizer *panGse = [[UIPanGestureRecognizer alloc]init];
    
    panGse.delegate = self;
    
    [panGse addTarget:self action:@selector(panGes:)];
    
    [self addGestureRecognizer:panGse];
    
}

//创建双击手势
-(void)createDoubleGesture
{
    UITapGestureRecognizer *doubleSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    
    doubleSingleTap.numberOfTapsRequired = 2; // 双击
    
    [self addGestureRecognizer:doubleSingleTap];
    
}

#pragma mark 处理手势

//处理缩放手势
static float _lastScale=0;static int  pinTag = 0;
-(void)pinchGes:(UIPinchGestureRecognizer *)ges
{
    if([ges state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0; pinTag = 1;
        return;
    }
    
    CGFloat scale = ges.scale;
    CGFloat scale1 = scale/_lastScale;
    
    ges.view.transform = CGAffineTransformScale(ges.view.transform, scale1, scale1);
    
    float centerX=[self.model.centerX floatValue];
    float centerY=[self.model.centerY floatValue];
    float w=[self.model.w floatValue];
    float h=[self.model.h floatValue];
    float x=centerX-(w*scale1)/2;
    float y=centerY-(h*scale1)/2;
    self.model.w = [NSString stringWithFormat:@"%f",w*scale1];
    self.model.h = [NSString stringWithFormat:@"%f",h*scale1];
    self.model.x = [NSString stringWithFormat:@"%f",x];
    self.model.y = [NSString stringWithFormat:@"%f",y];
    
    _lastScale=scale;

    [self operationPro];
    
    if (ges.state == UIGestureRecognizerStateCancelled || ges.state == UIGestureRecognizerStateEnded) {

        [self updateCtrolPoint:self.model];
        
        [self updateImagePoint:self.model];
        
        //单手势
        if (pinTag == 1 && panTag==0 && rotTag == 0) {
            
            pinTag = 0; panTag = 0 ; rotTag = 0;
            
            //成功调用
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(update)]) {
    
                [self.delegate update];
                
            }
            
        }else if (pinTag == 1 && ( panTag==1 || rotTag == 1)){  //拖动并缩放操作
            
            pinTag = 0; panTag = 0 ; rotTag = 0;

            self.model.angle = [NSString stringWithFormat:@"%f",angle+[self.model.angle floatValue]];
            
            angle = 0.0;
            
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(update)]) {
                    
                    [self.delegate update];
            }
            
        }
        
        
    }
    
}

//处理旋转手势
static float angle=0.0; static int rotTag = 0;
-(void)rotGes:(UIRotationGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateBegan) {
        rotTag = 1;
    }
    
    ges.view.transform = CGAffineTransformRotate(ges.view.transform, ges.rotation);
    
    angle += ges.rotation;
    
    [self degree];
    
    ges.rotation = 0;
    
    [self operationPro];
    
    if (ges.state == UIGestureRecognizerStateCancelled || ges.state == UIGestureRecognizerStateEnded) {

        [self updateCtrolPoint:self.model];
        
        [self updateImagePoint:self.model];

        //单手势
        if (pinTag == 0 && panTag==0 && rotTag == 1) {
            
            pinTag = 0; panTag = 0 ; rotTag = 0;
            
            self.model.angle = [NSString stringWithFormat:@"%f",angle+[self.model.angle floatValue]];

            angle = 0.0;
            
            //成功调用
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(update)]) {
                
                [self.delegate update];
            }
            
        }else if (rotTag == 1 && ( panTag==1 || pinTag == 1)){  //拖动并缩放操作
            
            pinTag = 0; panTag = 0 ; rotTag = 0;
   
            self.model.angle = [NSString stringWithFormat:@"%f",angle+[self.model.angle floatValue]];
            
            angle = 0.0;
        
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(update)]) {
                
                [self.delegate update];
                
            }
            
        }

        
    }
}

//处理拖动手势
static int panTag = 0;
-(void)panGes:(UIPanGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateBegan) {
        panTag = 1;
    }
    
    CGPoint point = [ges translationInView:ges.view];
    
    ges.view.transform = CGAffineTransformTranslate(ges.view.transform, point.x, point.y);
    
    [ges setTranslation:CGPointZero inView:ges.view];
    
    [self operationPro];
    
    if (ges.state == UIGestureRecognizerStateCancelled || ges.state == UIGestureRecognizerStateEnded) {

        [self updateCtrolPoint:self.model];
        
        [self updateImagePoint:self.model];
        
        //单手势
        if (pinTag == 0 && panTag==1 && rotTag == 0) {
            
            pinTag = 0; panTag = 0 ; rotTag = 0;
            
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(update)]) {
                
                [self.delegate update];
                
            }
            
        }else if (panTag == 1 && ( pinTag==1 || rotTag == 1)){  //拖动并缩放操作
            
            pinTag = 0; panTag = 0 ; rotTag = 0;
     
            
            self.model.angle = [NSString stringWithFormat:@"%f",angle+[self.model.angle floatValue]];
            
            angle = 0.0;
            
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(update)]) {
                
                [self.delegate update];
                
            }
        }
   
    }
    
}

#pragma mark 双击回正
//处理双击手势,(*由于双击回正是同时拖动4个点变形图片，当点拖动幅度大时造成变形错误，所以分5段回正过程，分越多效果越好)
static float afterTime = 0.03;
-(void)doubleTap:(UITapGestureRecognizer*)ges
{
    ges.view.transform = CGAffineTransformRotate(ges.view.transform,-[self.model.angle floatValue]/5);
    [self operationPro];
    [self performSelector:@selector(transform1) withObject:self afterDelay:afterTime];
    
}
-(void)transform1
{
    self.transform = CGAffineTransformRotate(self.transform,-[self.model.angle floatValue]/5);
    [self operationPro];
    [self performSelector:@selector(transform2) withObject:self afterDelay:afterTime];
    
}

-(void)transform2
{
    self.transform = CGAffineTransformRotate(self.transform,-[self.model.angle floatValue]/5);
    [self operationPro];
    [self performSelector:@selector(transform3) withObject:self afterDelay:afterTime];

}

-(void)transform3
{
    self.transform = CGAffineTransformRotate(self.transform,-[self.model.angle floatValue]/5);
    [self operationPro];
    [self performSelector:@selector(transform4) withObject:self afterDelay:afterTime];
}

-(void)transform4
{
    self.transform = CGAffineTransformRotate(self.transform,-[self.model.angle floatValue]/5);
    [self operationPro];
    [self updateCtrolPoint:self.model];
    self.model.angle = @"0";

    //成功调用
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(update)]) {
        
        [self.delegate update];
    }
    
}

#pragma mark 角度换算
-(void)degree
{
    // 将弧度转换为角度
    CGFloat degree = angle/M_PI * 180;
    NSString *str = [NSString stringWithFormat:@"%f",degree];
    
    if (degree>360 || degree<-360) {
        degree -= 360*([str intValue]/360);
        
    }else if(degree<-180){
        degree += 360;
        
    }else if (degree>180 && degree<360){
        degree -= 360;
    }
    angle = degree/180*M_PI;
}

#pragma mark 更改图片的frame
-(void)updateImagePoint:(YSKJ_drawModel*)model //更改图片的frame
{
    float centerX=self.proBut.centerX;
    float centerY=self.proBut.centerY;
    float w=[model.w floatValue];
    float h=[model.h floatValue];
    float x=centerX-w/2;
    float y=centerY-h/2;
    model.x = [NSString stringWithFormat:@"%f",x];
    model.y = [NSString stringWithFormat:@"%f",y];
    model.centerX = [NSString stringWithFormat:@"%f",centerX];
    model.centerY = [NSString stringWithFormat:@"%f",centerY];
}

#pragma mark 更改控制点的center
-(void)updateCtrolPoint:(YSKJ_drawModel*)model
{
    UIView *ltbut = [self.supView viewWithTag:[model.tag integerValue]+1000];
    UIView *rtbut = [self.supView viewWithTag:[model.tag integerValue]+1001];
    UIView *lbbut = [self.supView viewWithTag:[model.tag integerValue]+1002];
    UIView *rbbut = [self.supView viewWithTag:[model.tag integerValue]+1003];
    
    NSMutableArray *contorlPointArray = [[NSMutableArray alloc] initWithArray:model.contorlPoint];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (int i=0; i<contorlPointArray.count; i++) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        if (i==0) {
            [dict setValue:[NSString stringWithFormat:@"%f",ltbut.center.x] forKey:@"centerX"];
            [dict setValue:[NSString stringWithFormat:@"%f",ltbut.center.y] forKey:@"centerY"];
            [temp addObject:dict];
            
        }else if (i==1){
            [dict setValue:[NSString stringWithFormat:@"%f",rtbut.center.x] forKey:@"centerX"];
            [dict setValue:[NSString stringWithFormat:@"%f",rtbut.center.y] forKey:@"centerY"];
            [temp addObject:dict];
            
        }else if (i==2){
            [dict setValue:[NSString stringWithFormat:@"%f",lbbut.center.x] forKey:@"centerX"];
            [dict setValue:[NSString stringWithFormat:@"%f",lbbut.center.y] forKey:@"centerY"];
            [temp addObject:dict];
            
        }else{
            [dict setValue:[NSString stringWithFormat:@"%f",rbbut.center.x] forKey:@"centerX"];
            [dict setValue:[NSString stringWithFormat:@"%f",rbbut.center.y] forKey:@"centerY"];
            [temp addObject:dict];
        }
    }
    
    model.contorlPoint = temp;
    
}

#pragma mark 同时变形4个控制点
-(void)operationPro
{
    UIView *ltbut = [self.supView viewWithTag:[self.model.tag integerValue]+1000];
    UIView *rtbut = [self.supView viewWithTag:[self.model.tag integerValue]+1001];
    UIView *lbbut = [self.supView viewWithTag:[self.model.tag integerValue]+1002];
    UIView *rbbut = [self.supView viewWithTag:[self.model.tag integerValue]+1003];
    
    CGRect ltRect=[self convertRect:_ltView.frame toView:self.supView];
    ltbut.frame= CGRectMake(ltRect.origin.x+(ltRect.size.width-30)/2,ltRect.origin.y+(ltRect.size.height-30)/2, 30, 30);
    [self pop_animationStriong:kPOPLayerAGKQuadTopLeft forView:ltbut];
    
    CGRect rtRect=[self convertRect:_rtView.frame toView:self.supView];
    rtbut.frame= CGRectMake(rtRect.origin.x+(rtRect.size.width-30)/2,rtRect.origin.y+(rtRect.size.height-30)/2, 30, 30);
    [self pop_animationStriong:kPOPLayerAGKQuadTopRight forView:rtbut];
    
    CGRect lbRect=[self convertRect:_lbView.frame toView:self.supView];
    lbbut.frame= CGRectMake(lbRect.origin.x+(lbRect.size.width-30)/2,lbRect.origin.y+(lbRect.size.height-30)/2, 30, 30);
    [self pop_animationStriong:kPOPLayerAGKQuadBottomLeft forView:lbbut];
    
    CGRect rbRect=[self convertRect:_rbView.frame toView:self.supView];
    rbbut.frame= CGRectMake(rbRect.origin.x+(rbRect.size.width-30)/2,rbRect.origin.y+(rbRect.size.height-30)/2, 30, 30);
    [self pop_animationStriong:kPOPLayerAGKQuadBottomRight forView:rbbut];
    
}


#pragma mark POPSpringAnimation

-(void)pop_animationStriong:(NSString*)animationName forView:(UIView *)subView
{
    POPSpringAnimation *anim = [self.proBut.layer pop_animationForKey:animationName];
    if(anim == nil)
    {
        anim = [POPSpringAnimation animation];
        anim.property = [POPAnimatableProperty AGKPropertyWithName:animationName];
        [self.proBut.layer pop_addAnimation:anim forKey:animationName];
    }
    anim.toValue = [NSValue valueWithCGPoint:subView.center];
}

#pragma mark UIGestureRecognizerDelegate
//和其他手势一起进行
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
    
}


@end
