//
//  EPGraphView.m
//  Eat Princeton
//
//  Created by Charles Marsh on 11/9/12.
//  Copyright (c) 2012 Charles Marsh. All rights reserved.
//

#import "EPGraphView.h"
#import "EPViews.h"

#define STUB 5
#define OFFSET_Y 50
#define OFFSET_X 30
@interface EPGraphView() {
    double max;
    double min;
}
@property (nonatomic, strong) NSMutableSet *axisLabels;
@property (nonatomic, strong) UIColor *axisColor;
@property (nonatomic, strong) NSMutableArray *bars;
@property (nonatomic, strong) NSMutableArray *barLabels;
@property (nonatomic, strong) NSMutableArray *barTicks;
@end

@implementation EPGraphView

@synthesize dataSeries = _dataSeries, dataLabels = _dataLabels, dataColors = _dataColors;
@synthesize axisLabels = _axisLabels, axisColor = _axisColor;

#pragma mark - Setters and getters

- (void)setDataSeries:(NSArray *)dataSeries
{
    BOOL draw = (_dataColors && _dataLabels && !_dataSeries);
    _dataSeries = dataSeries;
    
    // calculate max and min (for axes)
    double max_t = DBL_MIN;
    double min_t = DBL_MAX;
    for (int i = 0; i < dataSeries.count; i++) {
        if ([[dataSeries objectAtIndex:i] doubleValue] > max_t)
            max_t = [[dataSeries objectAtIndex:i] doubleValue];
        if ([[dataSeries objectAtIndex:i] doubleValue] < min_t)
            min_t = [[dataSeries objectAtIndex:i] doubleValue];
    }
    max = max_t;
    min = min_t;
    
    if (draw) [self drawGraph];
}

- (void)setDataLabels:(NSArray *)dataLabels
{
    BOOL draw = (_dataColors && !_dataLabels && _dataSeries);
    _dataLabels = dataLabels;
    if (draw) [self drawGraph];
}

- (void)setDataColors:(NSArray *)dataColors
{
    BOOL draw = (!_dataColors && _dataLabels && _dataSeries);
    _dataColors = dataColors;
    if (draw) [self drawGraph];
}

- (NSMutableSet *)axisLabels
{
    if (!_axisLabels)
        _axisLabels = [NSMutableSet setWithCapacity:self.dataSeries.count];
    return _axisLabels;
}

- (UIColor *)axisColor
{
    if (!_axisColor)
        _axisColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
    return _axisColor;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawGraph
{
    [self drawAxes];
    [self drawLabels];
    [self drawData];
}

- (void)drawAxes
{
    int size = 1;
    UIView *yAxis = [[UIView alloc] initWithFrame:CGRectMake(OFFSET_X, 0, size, self.frame.size.height - OFFSET_Y + STUB + size)];
    UIView *xAxis = [[UIView alloc] initWithFrame:CGRectMake(OFFSET_X - STUB, self.frame.size.height - OFFSET_Y, self.frame.size.width - OFFSET_X + STUB, size)];
    yAxis.backgroundColor = self.axisColor;
    xAxis.backgroundColor = self.axisColor;
    [self addSubview:yAxis];
    [self addSubview:xAxis];
}

- (void)drawLabels
{
    int side_padding = 10;
    int top_padding = 8;
    double segmentWidth = (self.frame.size.width - OFFSET_X)/self.dataLabels.count;
    for (int i = 0; i < self.dataLabels.count; i++) {
        int initial = OFFSET_X + segmentWidth*i;
        UIView *backer = [[EPTransparentView alloc] initWithFrame:CGRectMake(initial + side_padding, self.frame.size.height - OFFSET_Y + top_padding, segmentWidth - 2*side_padding, segmentWidth - 2*side_padding)];
        [self addSubview:backer];
        
        UIImageView *logo = [[UIImageView alloc] initWithFrame:backer.bounds];
        logo.contentMode = UIViewContentModeScaleAspectFit;
        logo.image = [UIImage imageNamed:[self.dataLabels objectAtIndex:i]];
        logo.alpha = 0.8;
        [backer addSubview:logo];
    }
}

- (void)drawData
{
    self.bars = [NSMutableArray arrayWithCapacity:self.dataSeries.count];
    self.barTicks = [NSMutableArray arrayWithCapacity:self.dataSeries.count];
    self.barLabels = [NSMutableArray arrayWithCapacity:self.dataSeries.count];
    
    int padding = 15;
    double segmentWidth = (self.frame.size.width - OFFSET_X)/self.dataLabels.count;
    
    for (int i = 0; i < self.dataSeries.count; i++) {
        int initial = OFFSET_X + segmentWidth*i;
        
        double proportion = [[self.dataSeries objectAtIndex:i] doubleValue]/max;
        
        // draw bar
        EP3DBarView *bar = [[EP3DBarView alloc] initWithFrame:CGRectMake(initial + padding, (1-proportion)*(self.frame.size.height-OFFSET_Y), segmentWidth - 2*padding, proportion*(self.frame.size.height-OFFSET_Y))];
        bar.backgroundColor = [UIColor clearColor];
        bar.lightColor = [self.dataColors objectAtIndex:i];
        const float* colors = CGColorGetComponents(bar.lightColor.CGColor);
        bar.darkColor = [UIColor colorWithRed:.8*(*colors) green:.8*(*(colors+1)) blue:.8*(*(colors+2)) alpha:1.0];
        
        bar.outlineColor = [UIColor grayColor];
        
        UIGraphicsBeginImageContext(bar.bounds.size);
        [bar.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImage *barImage = [viewImage resizableImageWithCapInsets:UIEdgeInsetsMake(bar.backdrop_size + 5, 0, bar.backdrop_size + 5, 0)];
        UIImageView *barImageView = [[UIImageView alloc] initWithImage:barImage];
        barImageView.frame = CGRectMake(initial + padding, (1-proportion)*(self.frame.size.height-OFFSET_Y), segmentWidth - 2*padding, proportion*(self.frame.size.height-OFFSET_Y));
        
        [self addSubview:barImageView];
        [self.bars addObject:barImageView];
        
        // label axis
        // draw tick mark
        int h = 3;
        int w = 5;
        UIView *tick = [[UIView alloc] initWithFrame:CGRectMake(OFFSET_X - w, (1-proportion)*(self.frame.size.height-OFFSET_Y) + (([[self.dataSeries objectAtIndex:i] integerValue] > 0)? bar.backdrop_size : 0), w, h)];
        tick.backgroundColor = self.axisColor;
        [self addSubview:tick];
        [self.barTicks addObject:tick];
            
        // add numerical value
        h = 25;
        w = 40;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tick.frame.origin.x - w - 2, tick.frame.origin.y - h/2, w, h)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentRight;
        label.text = [NSString stringWithFormat:@"%d", [[self.dataSeries objectAtIndex:i] integerValue]];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [self addSubview:label];
        [self.barLabels addObject:label];
        [self.axisLabels addObject:[self.dataSeries objectAtIndex:i]];
    }
}

#pragma mark - Class methods
- (void)adjustDataSeries:(NSArray *)dataSeries overInterval:(NSTimeInterval)interval
{
    if (self.dataSeries.count != dataSeries.count) return;
    self.dataSeries = dataSeries;
    
    [UIView animateWithDuration:interval animations:^{
        int padding = 15;
        double segmentWidth = (self.frame.size.width - OFFSET_X)/self.dataLabels.count;
        
        for (int i = 0; i < self.bars.count; i++) {
            // reposition bar
            int initial = OFFSET_X + segmentWidth*i;
            double proportion = [[self.dataSeries objectAtIndex:i] doubleValue]/max;
            
            UIImageView *bar = [self.bars objectAtIndex:i];
            bar.frame = CGRectMake(initial + padding, (1-proportion)*(self.frame.size.height-OFFSET_Y), segmentWidth - 2*padding, proportion*(self.frame.size.height-OFFSET_Y));
            
            // resposition label
            int h = 3;
            int w = 5;
            UIView *tick = [self.barTicks objectAtIndex:i];
            tick.frame = CGRectMake(OFFSET_X - w, (1-proportion)*(self.frame.size.height-OFFSET_Y) + (([[self.dataSeries objectAtIndex:i] integerValue] > 0)? 8 : 0), w, h);
            
            // resposition numerical label
            h = 14;
            w = 40;
            UILabel *label = [self.barLabels objectAtIndex:i];
            label.frame = CGRectMake(tick.frame.origin.x - w - 2, tick.frame.origin.y - h/2, w, h);
            label.text = [NSString stringWithFormat:@"%d", [[self.dataSeries objectAtIndex:i] integerValue]];
        }
    }];
}

@end