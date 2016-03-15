//
//  IChecbox.h
//  IKit
//
//  Created by blutter on 16/3/14.
//  Copyright © 2016年 ideawu. All rights reserved.
//

#import "IView.h"

@interface IOption : IView

@property (nonatomic, getter=isOn) BOOL on;

@property (nonatomic, nullable) UIImageView *imageView;

- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state;

- (nullable UIImage *)imageForState:(UIControlState)state;

@end
