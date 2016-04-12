//
//  AKPolygonView.h
//  PolygonTestApp
//
//  Created by akiniru on 2016. 4. 6..
//  Copyright © 2016년 Rainbow Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AKPolygonView : UIView

typedef struct AKPointInfo {
    NSInteger pointKeyIndex;
    NSInteger indexKeyIndex;
    NSInteger pointIndex;
} AKPointInfo;

typedef struct LineSegment {
    CGPoint pt1;
    CGPoint pt2;
} LineSegment;

- (void)initAllPointsWithPointCount:(int)count;

@end
