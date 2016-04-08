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

typedef struct SearchedPointInfo {
    NSInteger searchedPointKeyIndex;
    NSInteger searchedIndexKeyIndex;
    NSInteger searchedPointIndex;
} SearchedPointInfo;

- (void)initAllPointsWithPointCount:(int)count;

@end
