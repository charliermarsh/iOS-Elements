//
//  EP3DBarView.h
//  Eat Princeton
//
//  Created by Charles Marsh on 11/10/12.
//  Copyright (c) 2012 Charles Marsh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EP3DBarView : UIView

@property (nonatomic, strong) UIColor *lightColor;
@property (nonatomic, strong) UIColor *darkColor;
@property (nonatomic, strong) UIColor *outlineColor;
@property (nonatomic) int backdrop_size;

@end