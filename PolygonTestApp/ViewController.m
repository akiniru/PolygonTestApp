//
//  ViewController.m
//  PolygonTestApp
//
//  Created by akiniru on 2016. 4. 6..
//  Copyright © 2016년 Rainbow Factory. All rights reserved.
//

#import "ViewController.h"

#import "AKPolygonView.h"
#import "AKPatternBrushView.h"
#import "AKLineDrawingView.h"

@interface ViewController ()

@property (nonatomic, strong) AKPolygonView *polygonView;
@property (nonatomic, strong) AKLineDrawingView *lineDrawingView;
@property (nonatomic, strong) AKPatternBrushView *patternBrushView;
@property (nonatomic, assign) int pointCount;

@end

@implementation ViewController

- (void)viewDidLoad
{
    NSLog(@"called");
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setup
{
    NSLog(@"called");
    [self generatePolygonView];
    // [self generateLineDrawingView];
    // [self generatePatternBrushView];
}

- (void)generatePolygonView
{
    NSLog(@"called");
    self.pointCount = 3;
    CGFloat rootViewWidth = self.view.frame.size.width;
    CGFloat polygonViewWidth = rootViewWidth;
    CGFloat polygonViewHeight = 320;
    CGRect polygonRect = CGRectMake(0, 20, polygonViewWidth, polygonViewHeight);
    self.polygonView = [[AKPolygonView alloc] initWithFrame:polygonRect];
    [self.view addSubview:self.polygonView];
    
    UIButton *countUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [countUpButton setTitle:@"Count Up" forState:UIControlStateNormal];
    [countUpButton setBackgroundColor:[UIColor blackColor]];
    countUpButton.frame = CGRectMake(100, polygonViewHeight, 100, 40);
    [countUpButton addTarget:self action:@selector(actionPointCountUp) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:countUpButton];
    
    UIButton *countDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [countDownButton setTitle:@"Count Down" forState:UIControlStateNormal];
    [countDownButton setBackgroundColor:[UIColor blackColor]];
    countDownButton.frame = CGRectMake(220, polygonViewHeight, 100, 40);
    [countDownButton addTarget:self action:@selector(actionPointCountDown) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:countDownButton];
}

- (void)actionPointCountUp
{
    NSLog(@"called");
    if (10 < self.pointCount)
    {
        return;
    }
    
    [self.polygonView initAllPointsWithPointCount:++self.pointCount];
}

- (void)actionPointCountDown
{
    NSLog(@"called");
    if (4 > self.pointCount)
    {
        return;
    }
    
    [self.polygonView initAllPointsWithPointCount:--self.pointCount];
}

- (void)generateLineDrawingView
{
    NSLog(@"called");
    self.lineDrawingView = [[AKLineDrawingView alloc] initWithFrame:CGRectMake(0, 44, 768, 1004)];
    [self.lineDrawingView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.lineDrawingView];
    
    UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [undoButton setTitle:@"UNDO" forState:UIControlStateNormal];
    [undoButton setBackgroundColor:[UIColor blackColor]];
    undoButton.frame = CGRectMake(100, 0, 100, 40);
    [undoButton addTarget:self action:@selector(actionUndo:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:undoButton];
    
    
    UIButton *redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [redoButton setTitle:@"REDO" forState:UIControlStateNormal];
    [redoButton setBackgroundColor:[UIColor blackColor]];
    redoButton.frame = CGRectMake(220, 0, 100, 40);
    [redoButton addTarget:self action:@selector(actionRedo:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:redoButton];
}

- (void)generatePatternBrushView
{
    NSLog(@"called");
    self.patternBrushView = [[AKPatternBrushView alloc] initWithFrame:CGRectMake(0, 44, 768, 1004)];
    [self.patternBrushView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.patternBrushView];
}

- (void)actionUndo:(id)sender
{
    NSLog(@"called");
    [self.lineDrawingView actionUndo];
}

- (void)actionRedo:(id)sender
{
    NSLog(@"called");
    [self.lineDrawingView actionRedo];
}

@end
