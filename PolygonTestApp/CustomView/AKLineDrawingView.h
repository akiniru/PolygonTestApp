//
//  AKLineDrawingView.h
//  PolygonTestApp
//
//  Created by akiniru on 2016. 4. 6..
//  Copyright © 2016년 Rainbow Factory. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AKLineDrawingView : UIView
{
    NSMutableArray *pathArray;
    NSMutableArray *bufferArray;
    UIBezierPath *myPath;
}

@property(nonatomic,assign) NSInteger undoSteps;

- (void)actionUndo;
- (void)actionRedo;

@end
