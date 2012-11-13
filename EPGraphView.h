//
//  EPGraphView.h
//  Eat Princeton
//
//  Created by Charles Marsh on 11/9/12.
//  Copyright (c) 2012 Charles Marsh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPGraphView : UIView

@property (nonatomic, strong) NSArray *dataSeries;
@property (nonatomic, strong) NSArray *dataLabels;
@property (nonatomic, strong) NSArray *dataColors;

- (void)adjustDataSeries:(NSArray *)dataSeries overInterval:(NSTimeInterval)interval;
- (void)drawGraph;

@end