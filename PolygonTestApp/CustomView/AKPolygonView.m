//
//  AKPolygonView.m
//  PolygonTestApp
//
//  Created by akiniru on 2016. 4. 6..
//  Copyright © 2016년 Rainbow Factory. All rights reserved.
//

#import "AKPolygonView.h"

#define MIN_POINT_COUNT         3
#define DEFAULT_POINT_COUNT     3

@interface AKPolygonView ()

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) NSMutableArray *pathArray;
@property (nonatomic, strong) UILongPressGestureRecognizer *gestureRecognizer;
@property (nonatomic, assign) NSInteger closestPointIndex;
@property (nonatomic, assign) CGFloat pointCount;
@property (nonatomic, assign) CGPoint touchStartPoint;

@end

@implementation AKPolygonView

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"called");
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"called");
    self.fillColor = nil;
    
    [self.pathArray removeAllObjects];
    self.pathArray = nil;
    
    [self removeGestureRecognizer:self.gestureRecognizer];
    self.gestureRecognizer = nil;
}

- (void)setup
{
    self.backgroundColor = [UIColor grayColor];
    self.fillColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.9];
    self.pathArray = [NSMutableArray array];
    self.pointCount = DEFAULT_POINT_COUNT;
    
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongPress:)];
    [self addGestureRecognizer:gestureRecognizer];
    
    [self initAllPoints];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSString *rectString = NSStringFromCGRect(rect);
    NSLog(@"called. rectString: %@, self.pathArray.count: %lu", rectString, (unsigned long)self.pathArray.count);
    
    if (nil == self.pathArray || 0 == self.pathArray.count)
    {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGContextRef graphContext = UIGraphicsGetCurrentContext();
    CGContextBeginPath(graphContext);
    CGPoint beginPoint = [[self.pathArray objectAtIndex:0] CGPointValue];
    CGContextMoveToPoint(graphContext, beginPoint.x, beginPoint.y);
    for (NSValue *pointValue in self.pathArray)
    {
        CGPoint point = [pointValue CGPointValue];
        CGContextAddLineToPoint(graphContext, point.x, point.y);
    }
    
    CGContextSetFillColorWithColor(graphContext, self.fillColor.CGColor);
    CGContextFillPath(graphContext);
}

- (void)initAllPoints
{
    CGFloat midPointX = CGRectGetMidX(self.bounds);
    CGFloat midPointY = CGRectGetMidY(self.bounds);
    CGFloat distanceFromCenter = self.bounds.size.width < self.bounds.size.height ? self.bounds.size.width / 3: self.bounds.size.height / 3;
    [self.pathArray removeAllObjects];
    NSLog(@"called. midPointX: %f, midPointY: %f", midPointX, midPointY);
    
    for (int i = 0; i < self.pointCount; ++i)
    {
        float x = midPointX + distanceFromCenter * cos(i / self.pointCount * 2 * M_PI - M_PI / 2);
        float y = midPointY + distanceFromCenter * sin(i / self.pointCount * 2 * M_PI - M_PI / 2);
        CGPoint point = CGPointMake(x, y);
        [self.pathArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    NSLog(@"self.pathArray: %@", self.pathArray);
}

- (void)initAllPointsWithPointCount:(NSInteger)count;
{
    NSLog(@"called");
    self.pointCount = count;
    [self initAllPoints];
    
    [self setNeedsDisplay];
}

- (void)actionLongPress:(UILongPressGestureRecognizer *)recognizer
{
    NSLog(@"called. recognizer.state: %ld", (long)recognizer.state);
    CGPoint touchPoint = [recognizer locationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.touchStartPoint = touchPoint;
        NSString *touchPointString = NSStringFromCGPoint(touchPoint);
        NSLog(@"touchPointString: %@", touchPointString);
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self moveAllPoints:touchPoint];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
    }
}

- (void)moveAllPoints:(CGPoint)touchPoint
{
    NSLog(@"called");
    CGFloat distanceX = touchPoint.x - self.touchStartPoint.x;
    CGFloat distanceY = touchPoint.y - self.touchStartPoint.y;
    NSLog(@"distanceX: %f, distanceY: %f", distanceX, distanceY);
    
    for (NSInteger i = 0; i < self.pathArray.count; i++) {
        NSValue *savedValue = [self.pathArray objectAtIndex:i];
        CGPoint savedPoint = [savedValue CGPointValue];
        NSLog(@"before savedPoint: %@", NSStringFromCGPoint(savedPoint));
        savedPoint.x = savedPoint.x + distanceX;
        savedPoint.y = savedPoint.y + distanceY;
        NSLog(@"after savedPoint: %@", NSStringFromCGPoint(savedPoint));
        NSValue *exchangePointValue = [NSValue valueWithCGPoint:savedPoint];
        [self.pathArray replaceObjectAtIndex:i withObject:exchangePointValue];
    }
    self.touchStartPoint = touchPoint;
    
    [self setNeedsDisplay];
}

#pragma mark - Touch Method
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat smallestDistance = MAXFLOAT;
    CGPoint closestPoint = centerPoint;
    NSInteger searchedIndex = -1;
    for (NSInteger i = 0; i < self.pathArray.count; i++) {
        NSValue *savedValue = [self.pathArray objectAtIndex:i];
        CGFloat distance = distanceBetweenTwoPoints(currentPoint, [savedValue CGPointValue]);
        if (distance < smallestDistance) {
            closestPoint = [savedValue CGPointValue];
            smallestDistance = distance;
            searchedIndex = i;
        }
    }
    
    self.closestPointIndex = searchedIndex;
    NSLog(@"searchedIndex: %lu", searchedIndex);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    NSValue *pointValue = [NSValue valueWithCGPoint:currentPoint];
    [self.pathArray replaceObjectAtIndex:self.closestPointIndex withObject:pointValue];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
}

#pragma mark - Static Method
static CGFloat distanceBetweenTwoPoints(CGPoint point1, CGPoint point2)
{
    NSLog(@"called");
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx * dx + dy * dy);
};

@end
