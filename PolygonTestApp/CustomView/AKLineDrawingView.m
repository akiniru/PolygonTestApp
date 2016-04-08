//
//  AKLineDrawingView.m
//  PolygonTestApp
//
//  Created by akiniru on 2016. 4. 6..
//  Copyright © 2016년 Rainbow Factory. All rights reserved.
//

#import "AKLineDrawingView.h"

@implementation AKLineDrawingView

@synthesize undoSteps;

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"called");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        pathArray = [[NSMutableArray alloc] init];
        bufferArray = [[NSMutableArray alloc] init];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"called");
    [[UIColor redColor] setStroke];
    for (UIBezierPath *_path in pathArray)
    {
        [_path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
}

#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
    myPath = [[UIBezierPath alloc] init];
    myPath.lineWidth = 10;
    
    UITouch *mytouch = [[touches allObjects] objectAtIndex:0];
    [myPath moveToPoint:[mytouch locationInView:self]];
    [pathArray addObject:myPath];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
    UITouch *mytouch = [[touches allObjects] objectAtIndex:0];
    [myPath addLineToPoint:[mytouch locationInView:self]];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
}

- (void)actionUndo
{
    NSLog(@"called");
    if ([pathArray count] > 0)
    {
        UIBezierPath *_path = [pathArray lastObject];
        [bufferArray addObject:_path];
        [pathArray removeLastObject];
        [self setNeedsDisplay];
    }
}

- (void)actionRedo
{
    NSLog(@"called");
    if ([bufferArray count] > 0)
    {
        UIBezierPath *_path = [bufferArray lastObject];
        [pathArray addObject:_path];
        [bufferArray removeLastObject];
        [self setNeedsDisplay];
    }
}

- (void)dealloc
{
    // [pathArray release];
    // [bufferArray release];
    // [super dealloc];
}

@end
