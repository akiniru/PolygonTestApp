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
@property (nonatomic, assign) AKPointInfo *searchedPointInfo;
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
    [gestureRecognizer setMinimumPressDuration:0.3];
    [self addGestureRecognizer:gestureRecognizer];
    
    [self initAllPoints:DEFAULT_POINT_COUNT];
    
    [self initAllPoints:4];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSString *rectString = NSStringFromCGRect(rect);
    NSLog(@"called. rectString: %@", rectString);
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

- (void)initAllPoints:(int)count
{
    NSLog(@"called");
    int index = 0;
    int pointCount = count;
    NSString *pointKeyString = [@(pointCount) stringValue];
    NSMutableDictionary *polygonsDic = [self.polygonsListDic objectForKey:pointKeyString];
    NSLog(@"polygonsDic is nil: %@", NSStringFromObjectIsNill(polygonsDic));
    if (nil == polygonsDic)
    {
        polygonsDic = [NSMutableDictionary dictionary];
        [self.polygonsListDic setObject:polygonsDic forKey:pointKeyString];
    }
    
    index = (int)[polygonsDic allKeys].count;
    NSString *indexKeyString = [@(index) stringValue];
    NSMutableArray *polygonPathArray = [NSMutableArray array];
    [polygonsDic setObject:polygonPathArray forKey:indexKeyString];
    
    CGFloat midPointX = CGRectGetMidX(self.bounds);
    CGFloat midPointY = CGRectGetMidY(self.bounds);
    CGFloat distanceFromCenter = self.bounds.size.width < self.bounds.size.height ? self.bounds.size.width / 3: self.bounds.size.height / 3;
    NSLog(@"pointCount: %d, midPointX: %f, midPointY: %f", pointCount, midPointX, midPointY);
    for (int i = 0; i < pointCount; ++i)
    {
        float x = midPointX + distanceFromCenter * cos(i / (float)pointCount * 2 * M_PI - M_PI / 2);
        float y = midPointY + distanceFromCenter * sin(i / (float)pointCount * 2 * M_PI - M_PI / 2);
        CGPoint point = CGPointMake(x, y);
        [polygonPathArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    NSLog(@"polygonPathArray: %@", polygonPathArray);
}

- (void)initAllPointsWithPointCount:(int)count
{
    NSLog(@"called");
    [self.polygonsListDic removeAllObjects];
    [self initAllPoints:count];
    
    [self setNeedsDisplay];
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
    for (int i = 0; i < polygonPathArray.count; ++i)
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

- (AKPointInfo *)searchClosestPoint:(CGPoint)touchPoint
{
    NSLog(@"called");
    NSLog(@"self.polygonsDic.count: %lu", self.polygonsListDic.count);
    CGFloat smallestDistance = MAXFLOAT;
    
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
                    smallestDistance = distance;
                    
                    searchedPointKeyIndex = i;
                    searchedIndexKeyIndex = k;
                    searchedPointIndex = j;
                }
            }
        }
    }
    
    NSLog(@"searchedPointKeyIndex: %ld, searchedIndexKeyIndex: %ld, searchedPointIndex: %ld", (long)searchedPointKeyIndex, (long)searchedIndexKeyIndex, (long)searchedPointIndex);
    AKPointInfo *searchedPointInfo = (AKPointInfo *)malloc(sizeof(AKPointInfo));
    searchedPointInfo->pointKeyIndex = searchedPointKeyIndex;
    searchedPointInfo->indexKeyIndex = searchedIndexKeyIndex;
    searchedPointInfo->pointIndex = searchedPointIndex;
    return searchedPointInfo;
}

- (NSMutableArray *)searchPolygonPathArray:(AKPointInfo *)searchedPointInfo
{
    NSArray *polygonsListKeyArray = [self.polygonsListDic allKeys];
    NSString *pointKeyString = [polygonsListKeyArray objectAtIndex:searchedPointInfo->pointKeyIndex];
    NSMutableDictionary *polygonsDic = [self.polygonsListDic objectForKey:pointKeyString];
    NSArray *polygonsKeyArray = [polygonsDic allKeys];
    NSString *indexKeyString = [polygonsKeyArray objectAtIndex:searchedPointInfo->indexKeyIndex];
    NSMutableArray *polygonPathArray = [polygonsDic objectForKey:indexKeyString];
    
    return polygonPathArray;
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
        AKPointInfo *searchedPointInfo = [self searchClosestPoint:touchPoint];
        self.searchedPointInfo = searchedPointInfo;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self moveAllPoints:touchPoint];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
    }
}

#pragma mark - Touch Method
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"called");
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    AKPointInfo *searchedPointInfo = [self searchClosestPoint:touchPoint];
    self.searchedPointInfo = searchedPointInfo;
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
    int pointCount = (int)polygonPathArray.count;
    //    if (3 < pointCount)
    //    {
    //        BOOL prevLeft = YES;
    //        for (int i = 0; i < pointCount - 2; ++i)
    //        {
    //            int centerIndex = (int)self.searchedPointInfo->pointIndex;
    //            int point1Index = (self.searchedPointInfo->pointIndex + i + 1) % pointCount;
    //            int point2Index = (self.searchedPointInfo->pointIndex + i + 2) % pointCount;
    //            NSLog(@"[%d] centerIndex: %d, point1Index: %d, point2Index: %d", i, centerIndex, point1Index, point2Index);
    //            NSValue *centerValue = [polygonPathArray objectAtIndex:centerIndex];
    //            NSValue *point1Value = [polygonPathArray objectAtIndex:point1Index];
    //            NSValue *point2Value = [polygonPathArray objectAtIndex:point2Index];
    //            CGPoint centerPoint = [centerValue CGPointValue];
    //            CGPoint pointOfLine1 = [point1Value CGPointValue];
    //            CGPoint pointOfLine2 = [point2Value CGPointValue];
    //            CGFloat distanceByTouchPoint = distanceLintToPoint(pointOfLine1, pointOfLine2, touchPoint);
    //            CGFloat distance = distanceLintToPoint(pointOfLine1, pointOfLine2, centerPoint);
    //            BOOL isLeft = checkLeft(pointOfLine1, pointOfLine2, touchPoint);
    //            NSLog(@"[%d] distance: %f, distanceByTouchPoint: %f, isLeft: %@", i, distance, distanceByTouchPoint, NSStringFromBOOL(isLeft));
    //
    //            if (i == 0)
    //            {
    //                prevLeft = isLeft;
    //                continue;
    //            }
    //            if (prevLeft != isLeft) {
    //                return;
    //            }
    //        }
    //    }
    
    if (3 < pointCount)
    {
        int centerIndex = (int)self.searchedPointInfo->pointIndex;
        int point1Index = (pointCount + centerIndex - 1) % pointCount;
        int point2Index = (pointCount + centerIndex + 1) % pointCount;
        NSLog(@"centerIndex: %d, point1Index: %d, point2Index: %d", centerIndex, point1Index, point2Index);
        // NSValue *centerValue = [polygonPathArray objectAtIndex:centerIndex];
        NSValue *point1Value = [polygonPathArray objectAtIndex:point1Index];
        NSValue *point2Value = [polygonPathArray objectAtIndex:point2Index];
        // CGPoint centerPoint = [centerValue CGPointValue];
        CGPoint centerPoint = touchPoint;
        CGPoint pointOfLine1 = [point1Value CGPointValue];
        CGPoint pointOfLine2 = [point2Value CGPointValue];
        LineSegment *ab = (LineSegment *)malloc(sizeof(LineSegment));
        ab->pt1 = centerPoint;
        ab->pt2 = pointOfLine1;
        int isIntersection = 0;
        for (int i = 0; i < pointCount - 2; ++i)
        {
            int tempPoint1Index = (pointCount + centerIndex + i + 1) % pointCount;
            int tempPoint2Index = (pointCount + centerIndex + i + 2) % pointCount;
            NSLog(@"[%d] centerIndex: %d, tempPoint1Index: %d, tempPoint2Index: %d", i, centerIndex, tempPoint1Index, tempPoint2Index);
            if (point1Index == tempPoint2Index)
            {
                break;
            }
            NSValue *tempPoint1Value = [polygonPathArray objectAtIndex:tempPoint1Index];
            NSValue *tempPoint2Value = [polygonPathArray objectAtIndex:tempPoint2Index];
            CGPoint tempPointOfLine1 = [tempPoint1Value CGPointValue];
            CGPoint tempPointOfLine2 = [tempPoint2Value CGPointValue];
            LineSegment *cd = (LineSegment *)malloc(sizeof(LineSegment));
            cd->pt1 = tempPointOfLine1;
            cd->pt2 = tempPointOfLine2;
            isIntersection += intersection(ab, cd);
            NSLog(@"[%d] isIntersection: %d", i, isIntersection);
            if (0 < isIntersection)
            {
                return;
            }
        }
        
        ab->pt1 = centerPoint;
        ab->pt2 = pointOfLine2;
        for (int i = 0; i < pointCount - 2; ++i)
        {
            int tempPoint1Index = (pointCount + centerIndex - i - 1) % pointCount;
            int tempPoint2Index = (pointCount + centerIndex - i - 2) % pointCount;
            NSLog(@"[%d] centerIndex: %d, tempPoint1Index: %d, tempPoint2Index: %d", i, centerIndex, tempPoint1Index, tempPoint2Index);
            if (point2Index == tempPoint2Index)
            {
                break;
            }
            NSValue *tempPoint1Value = [polygonPathArray objectAtIndex:tempPoint1Index];
            NSValue *tempPoint2Value = [polygonPathArray objectAtIndex:tempPoint2Index];
            CGPoint tempPointOfLine1 = [tempPoint1Value CGPointValue];
            CGPoint tempPointOfLine2 = [tempPoint2Value CGPointValue];
            LineSegment *cd = (LineSegment *)malloc(sizeof(LineSegment));
            cd->pt1 = tempPointOfLine1;
            cd->pt2 = tempPointOfLine2;
            isIntersection += intersection(ab, cd);
            NSLog(@"[%d] isIntersection: %d", i, isIntersection);
            if (0 < isIntersection)
            {
                return;
            }
        }
    }
    
    NSValue *pointValue = [NSValue valueWithCGPoint:touchPoint];
    [polygonPathArray replaceObjectAtIndex:self.searchedPointInfo->pointIndex withObject:pointValue];
    
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

//static CGFloat distanceLintToPoint(CGPoint pointOfLine1, CGPoint pointOfLine2, CGPoint centerPoint)
//{
//    CGFloat segment_mag = (pointOfLine2.x - pointOfLine1.x) * (pointOfLine2.x - pointOfLine1.x) + (pointOfLine2.y - pointOfLine1.y) * (pointOfLine2.y - pointOfLine1.y);
//    CGFloat distance;
//    if (0 != segment_mag)
//    {
//        CGFloat u = ((centerPoint.x - pointOfLine1.x) * (pointOfLine2.x - pointOfLine1.x) + (centerPoint.y - pointOfLine1.y) * (pointOfLine2.y - pointOfLine1.y)) / segment_mag;
//        CGFloat xp = pointOfLine1.x + u * (pointOfLine2.x - pointOfLine1.x);
//        CGFloat yp = pointOfLine1.y + u * (pointOfLine2.y - pointOfLine1.y);
//        distance = sqrt((xp - centerPoint.x) * (xp - centerPoint.x) + (yp - centerPoint.y) * (yp - centerPoint.y));
//    }
//    else
//    {
//        distance = sqrt((centerPoint.x - pointOfLine1.x) * (centerPoint.x - pointOfLine1.x) + (centerPoint.y - pointOfLine1.y) * (centerPoint.y - pointOfLine1.y));
//    }
//
//    return distance;
//}
//
//static BOOL checkLeft(CGPoint pointOfLine1, CGPoint pointOfLine2, CGPoint centerPoint)
//{
//    BOOL isLeft = NO;
//    CGFloat result = (pointOfLine1.x * pointOfLine2.y) + (pointOfLine2.x * centerPoint.y) + (centerPoint.x * pointOfLine1.y) - (pointOfLine1.x * centerPoint.y) - (pointOfLine2.x * pointOfLine1.y) - (centerPoint.x * pointOfLine2.y);
//    if (0 < result)
//    {
//        isLeft = YES;
//    }
//
//    return isLeft;
//}
//
//static CGFloat interiorAngleFromPoint(CGPoint centerPoint, CGPoint point0, CGPoint point1)
//{
//    CGFloat p0c = sqrt(powf(centerPoint.x - point0.x, 2) + powf(centerPoint.y - point0.y, 2)); // p0->c (b)
//    CGFloat p1c = sqrt(powf(centerPoint.x - point1.x, 2) + powf(centerPoint.y - point1.y, 2)); // p1->c (a)
//    CGFloat p0p1 = sqrt(powf(point1.x - point0.x, 2) + powf(point1.y - point0.y, 2)); // p0->p1 (c)
//    CGFloat value = acosf((p1c * p1c + p0c * p0c - p0p1 * p0p1) / (2 * p1c * p0c));
//    return value * 180 / M_PI;
//}

static int direction(CGPoint A, CGPoint B, CGPoint C)
{
    CGFloat dxAB, dxAC, dyAB, dyAC;
    int dir = 0;
    dxAB = B.x - A.x;
    dyAB = B.y - A.y;
    dxAC = C.x - A.x;
    dyAC = C.y - A.y;
    if (dxAB * dyAC < dyAB * dxAC) // 시계방향
    {
        dir = 1;
    }
    if (dxAB * dyAC > dyAB * dxAC) // 반시계방향
    {
        dir  = -1;
    }
    if (dxAB * dyAC == dyAB * dxAC) // 일직선 상에 있는 경우
    {
        if (dxAB == 0 && dyAB == 0)
        {
            dir = 0; // A = B
        }
        else if ((dxAB * dxAC < 0) || (dyAB * dyAC < 0))
        {
            dir = -1; // A가 가운데
        }
        else if ((dxAB * dxAB + dyAB * dyAB) >= (dxAC * dxAC + dyAC * dyAC))
        {
            dir = 0; // C가 가운데
        }
        else
        {
            dir = 1; // B가 가운데
        }
    }
    
    return dir;
}

int intersection(LineSegment *ab, LineSegment *cd)
{
    int lineCrossing = 0;
    if ((direction(ab->pt1, ab->pt2, cd->pt1) * direction(ab->pt1, ab->pt2, cd->pt2) <= 0)
        && (direction(cd->pt1, cd->pt2, ab->pt1) * direction(cd->pt1, cd->pt2, ab->pt2) <= 0))
    {
        lineCrossing = 1;
    }
    else
    {
        lineCrossing = 0;
    }
    
    return lineCrossing;
}

@end
