//
//  AKPolygonView.m
//  PolygonTestApp
//
//  Created by akiniru on 2016. 4. 6..
//  Copyright © 2016년 Rainbow Factory. All rights reserved.
//

#import "AKPolygonView.h"

#define DEFAULT_POINT_COUNT     3

@interface AKPolygonView ()

// polygonsListDic
//    | Key: Point
//    |--- NSMutableDictionary (3개의 점을 가지는 도형의 목록)
//          | Key: Index
//          |--- NSMutableArray (도형)
//                |-------- Point
//                |-------- Point
//                |-------- Point
//          |--- NSMutableArray (도형)
//                |-------- Point
//                |-------- Point
//                |-------- Point
//    |--- NSMutableArray (4개의 점을 가지는 도형의 목록)
//          |--- NSMutableArray (도형)
//                |-------- Point
//                |-------- Point
//                |-------- Point
//                |-------- Point

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) NSMutableDictionary *polygonsListDic;
@property (nonatomic, strong) UILongPressGestureRecognizer *gestureRecognizer;
@property (nonatomic, assign) SearchedPointInfo *searchedPointInfo;
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
    
    [self.polygonsListDic removeAllObjects];
    self.polygonsListDic = nil;
    
    [self removeGestureRecognizer:self.gestureRecognizer];
    self.gestureRecognizer = nil;
}

- (void)setup
{
    self.backgroundColor = [UIColor grayColor];
    self.fillColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.9];
    self.polygonsListDic = [NSMutableDictionary dictionary];
    
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongPress:)];
    [self addGestureRecognizer:gestureRecognizer];
    
    [self initAllPoints:DEFAULT_POINT_COUNT];
    
    [self initAllPoints:4];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSString *rectString = NSStringFromCGRect(rect);
    NSLog(@"called. rectString: %@, self.polygonsDic.count: %lu", rectString, (unsigned long)self.polygonsListDic.count);
    if (nil == self.polygonsListDic || 0 == self.polygonsListDic.count)
    {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    NSArray *polygonsListKeyArray = [self.polygonsListDic allKeys];
    for (int i = 0; i < polygonsListKeyArray.count; ++i)
    {
        // 도형 형태 획득
        NSString *pointKeyString = [polygonsListKeyArray objectAtIndex:i];
        NSMutableDictionary *polygonsDic = [self.polygonsListDic objectForKey:pointKeyString];
        NSArray *polygonsKeyArray = [polygonsDic allKeys];
        NSLog(@"polygonsListKeyArray[%d].pointKeyString: %@", i, pointKeyString);
        for (int k = 0; k < polygonsKeyArray.count; ++k)
        {
            // 점 목록 획득
            NSString *indexKeyString = [polygonsKeyArray objectAtIndex:k];
            NSMutableArray *polygonPathArray = [polygonsDic objectForKey:indexKeyString];
            NSLog(@"polygonsListKeyArray[%d].polygonsListKeyArray[%d].indexKeyString: %@", i, k, indexKeyString);
            
            CGContextRef graphContext = UIGraphicsGetCurrentContext();
            CGContextBeginPath(graphContext);
            CGPoint beginPoint = [[polygonPathArray objectAtIndex:0] CGPointValue];
            CGContextMoveToPoint(graphContext, beginPoint.x, beginPoint.y);
            for (NSValue *pointValue in polygonPathArray)
            {
                CGPoint point = [pointValue CGPointValue];
                CGContextAddLineToPoint(graphContext, point.x, point.y);
            }
            
            CGContextSetFillColorWithColor(graphContext, self.fillColor.CGColor);
            CGContextFillPath(graphContext);
        }
    }
}

- (void)initAllPoints:(NSInteger)count
{
    NSLog(@"called");
    int index = 0;
    CGFloat pointCount = count;
    NSString *pointKeyString = [@(pointCount) stringValue];
    NSMutableDictionary *polygonsDic = [self.polygonsListDic objectForKey:pointKeyString];
    NSLog(@"polygonsDic is nil: %@", NSStringFromObjectIsNill(polygonsDic));
    NSMutableArray *polygonPathArray;
    if (nil == polygonsDic)
    {
        polygonsDic = [NSMutableDictionary dictionary];
        NSString *indexKeyString = [@(index) stringValue];
        polygonPathArray = [NSMutableArray array];
        [polygonsDic setObject:polygonPathArray forKey:indexKeyString];
        [self.polygonsListDic setObject:polygonsDic forKey:pointKeyString];
    }
    [polygonPathArray removeAllObjects];
    
    CGFloat midPointX = CGRectGetMidX(self.bounds);
    CGFloat midPointY = CGRectGetMidY(self.bounds);
    CGFloat distanceFromCenter = self.bounds.size.width < self.bounds.size.height ? self.bounds.size.width / 3: self.bounds.size.height / 3;
    NSLog(@"pointCount: %f, midPointX: %f, midPointY: %f", pointCount, midPointX, midPointY);
    for (int i = 0; i < pointCount; ++i)
    {
        float x = midPointX + distanceFromCenter * cos(i / pointCount * 2 * M_PI - M_PI / 2);
        float y = midPointY + distanceFromCenter * sin(i / pointCount * 2 * M_PI - M_PI / 2);
        CGPoint point = CGPointMake(x, y);
        NSLog(@"index: %d, point: %@", i, NSStringFromCGPoint(point));
        [polygonPathArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    NSLog(@"polygonPathArray: %@", polygonPathArray);
}

- (void)initAllPointsWithPointCount:(NSInteger)count;
{
    NSLog(@"called");
    [self.polygonsListDic removeAllObjects];
    [self initAllPoints:count];
    
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
        SearchedPointInfo *pointInfo = [self searchClosestPoint:touchPoint];
        self.searchedPointInfo = pointInfo;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self moveAllPoints:touchPoint];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
    }
}

- (SearchedPointInfo *)searchClosestPoint:(CGPoint)touchPoint
{
    NSLog(@"called");
    NSLog(@"self.polygonsDic.count: %lu", self.polygonsListDic.count);
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat smallestDistance = MAXFLOAT;
    CGPoint closestPoint = centerPoint;
    
    NSInteger searchedPointKeyIndex = -1;
    NSInteger searchedIndexKeyIndex = -1;
    NSInteger searchedPointIndex = -1;
    
    NSArray *polygonsListKeyArray = [self.polygonsListDic allKeys];
    for (int i = 0; i < polygonsListKeyArray.count; ++i)
    {
        // 도형 형태 획득
        NSString *pointKeyString = [polygonsListKeyArray objectAtIndex:i];
        NSMutableDictionary *polygonsDic = [self.polygonsListDic objectForKey:pointKeyString];
        NSArray *polygonsKeyArray = [polygonsDic allKeys];
        NSLog(@"polygonsListKeyArray[%d].pointKeyString: %@", i, pointKeyString);
        for (int k = 0; k < polygonsKeyArray.count; ++k)
        {
            // 점 목록 획득
            NSString *indexKeyString = [polygonsKeyArray objectAtIndex:k];
            NSMutableArray *polygonPathArray = [polygonsDic objectForKey:indexKeyString];
            NSLog(@"polygonsListKeyArray[%d].polygonsListKeyArray[%d].indexKeyString: %@", i, k, indexKeyString);
            for (int j = 0; j < polygonPathArray.count; ++j)
            {
                // 근접한 점 확인
                NSValue *savedValue = [polygonPathArray objectAtIndex:j];
                CGFloat distance = distanceBetweenTwoPoints(touchPoint, [savedValue CGPointValue]);
                if (distance < smallestDistance)
                {
                    closestPoint = [savedValue CGPointValue];
                    smallestDistance = distance;
                    
                    searchedPointKeyIndex = i;
                    searchedIndexKeyIndex = k;
                    searchedPointIndex = j;
                }
            }
        }
    }
    
    NSLog(@"searchedPointKeyIndex: %ld, searchedIndexKeyIndex: %ld, searchedPointIndex: %ld", (long)searchedPointKeyIndex, (long)searchedIndexKeyIndex, (long)searchedPointIndex);
    SearchedPointInfo *pointInfo = (SearchedPointInfo *) malloc(sizeof(SearchedPointInfo));
    pointInfo->searchedPointKeyIndex = searchedPointKeyIndex;
    pointInfo->searchedIndexKeyIndex = searchedIndexKeyIndex;
    pointInfo->searchedPointIndex = searchedPointIndex;
    return pointInfo;
}

- (void)moveAllPoints:(CGPoint)touchPoint
{
    NSLog(@"called");
    CGFloat distanceX = touchPoint.x - self.touchStartPoint.x;
    CGFloat distanceY = touchPoint.y - self.touchStartPoint.y;
    self.touchStartPoint = touchPoint;
    NSLog(@"distanceX: %f, distanceY: %f", distanceX, distanceY);
    
    NSMutableArray *polygonPathArray = [self searchPolygonPathArray:self.searchedPointInfo];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSInteger i = 0; i < polygonPathArray.count; i++)
    {
        NSValue *savedValue = [polygonPathArray objectAtIndex:i];
        CGPoint savedPoint = [savedValue CGPointValue];
        NSLog(@"before savedPoint: %@", NSStringFromCGPoint(savedPoint));
        savedPoint.x = savedPoint.x + distanceX;
        savedPoint.y = savedPoint.y + distanceY;
        NSLog(@"after savedPoint: %@", NSStringFromCGPoint(savedPoint));
        
        if (savedPoint.x < 0 || savedPoint.x > self.bounds.size.width || savedPoint.y < 0 || savedPoint.y > self.bounds.size.height)
        {
            return;
        }
        
        NSValue *newPointValue = [NSValue valueWithCGPoint:savedPoint];
        [tempArray addObject:newPointValue];
    }
    [polygonPathArray removeAllObjects];
    [polygonPathArray addObjectsFromArray:tempArray];
    
    [self setNeedsDisplay];
}

- (NSMutableArray *)searchPolygonPathArray:(SearchedPointInfo *)searchedPointInfo
{
    NSArray *polygonsListKeyArray = [self.polygonsListDic allKeys];
    NSString *pointKeyString = [polygonsListKeyArray objectAtIndex:self.searchedPointInfo->searchedPointKeyIndex];
    NSMutableDictionary *polygonsDic = [self.polygonsListDic objectForKey:pointKeyString];
    NSArray *polygonsKeyArray = [polygonsDic allKeys];
    NSString *indexKeyString = [polygonsKeyArray objectAtIndex:self.searchedPointInfo->searchedIndexKeyIndex];
    NSMutableArray *polygonPathArray = [polygonsDic objectForKey:indexKeyString];
    
    return polygonPathArray;
}

#pragma mark - Touch Method
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    SearchedPointInfo *pointInfo = [self searchClosestPoint:touchPoint];
    self.searchedPointInfo = pointInfo;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (touchPoint.x < 0 || touchPoint.x > self.bounds.size.width || touchPoint.y < 0 || touchPoint.y > self.bounds.size.height)
    {
        return;
    }
    
    
    NSMutableArray *polygonPathArray = [self searchPolygonPathArray:self.searchedPointInfo];
    NSValue *pointValue = [NSValue valueWithCGPoint:touchPoint];
    [polygonPathArray replaceObjectAtIndex:self.searchedPointInfo->searchedPointIndex withObject:pointValue];
    
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
