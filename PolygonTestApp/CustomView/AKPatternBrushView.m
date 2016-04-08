//
//  AKPatternBrushView.m
//  PolygonTestApp
//
//  Created by akiniru on 2016. 4. 6..
//  Copyright © 2016년 Rainbow Factory. All rights reserved.
//

#import "AKPatternBrushView.h"

@implementation AKPatternBrushView

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"called");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        myPath = [[UIBezierPath alloc] init];
        myPath.lineWidth = 10;
        // brushPattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.jpg"]];
        brushPattern = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pattern.jpg"]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"called");
    [brushPattern setStroke];
    [myPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
    // Drawing code
    // [myPath stroke];
}

#pragma mark - Touch Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
    UITouch *mytouch = [[touches allObjects] objectAtIndex:0];
    [myPath moveToPoint:[mytouch locationInView:self]];
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

- (void)dealloc
{
    // [brushPattern release];
    // [super dealloc];
}

@end
