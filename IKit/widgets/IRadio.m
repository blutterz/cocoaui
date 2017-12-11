//
//  IChecbox.m
//  IKit
//
//  Created by blutter on 16/3/14.
//  Copyright © 2016年 ideawu. All rights reserved.
//

#import "IRadio.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"
#import "IResourceMananger.h"

@interface IRadio(){
    UIImageView *_imageView;
    void (^_changeHandler)(IEventType, IView *);
}

@property (nonatomic) UIImage*      normalImage;
@property (nonatomic) UIImage*      hotImage;
@property (nonatomic) UIImage*      selectedImage;
@property (nonatomic) UIImage*      selectedHotImage;

@end

@implementation IRadio

- (instancetype)init {
    self = [super init];
    if (self) {
        self.style.tagName = @"radio";
    }
    return self;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state{
    switch (state) {
        case UIControlStateNormal:
        {
            _normalImage = image;
            if (![self isOn]) {
                [self.imageView setImage:_normalImage];
                [self setNeedsLayout];
            }
        }
            break;
        case UIControlStateSelected:
        {
            _selectedImage = image;
            if ([self isOn]) {
                [self.imageView setImage:_selectedImage];
                [self setNeedsLayout];
            }
        }
            break;
        case UIControlStateHighlighted:
        {
            _hotImage = image;
        }
            break;
        case UIControlStateFocused:
        {
            _selectedHotImage = image;
        }
            break;
        default:
            break;
    }
}

- (UIImageView *)imageView{
    if(!_imageView){
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self addUIView:_imageView];
    }
    return _imageView;
}

- (void)setImageView:(UIImageView *)imageView{
    if(_imageView){
        [_imageView removeFromSuperview];
    }
    _imageView = imageView;
    [self addUIView:_imageView];
}

- (UIImage*)imageForState:(UIControlState)state{
    switch (state) {
        case UIControlStateNormal:
            return _normalImage;
            break;
        case UIControlStateSelected:
            return _selectedImage;
            break;
        case UIControlStateHighlighted:
            return _hotImage;
            break;
        case UIControlStateFocused:
            return _selectedHotImage;
            break;
        default:
            break;
    }
    return nil;
}

- (void) setOn:(BOOL)on {
    if ([self isOn] == on) {
        return;
    }
    _on = on;
    if (_on && _selectedImage) {
        [self.imageView setImage:_selectedImage];
        [self setNeedsLayout];
    }
    if (!_on && _normalImage) {
        [self.imageView setImage:_normalImage];
        [self setNeedsLayout];
    }
    [self performSelector:@selector(fireChangeEvent) withObject:nil afterDelay:0.15];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
}

- (void)layout{
    //log_debug(@"%@ %s %@", self.name, __func__, _src);
    
    if(_imageView){
        [_imageView sizeToFit];
        if(self.style.resizeWidth){
            NSLog(@"width: %f", _imageView.frame.size.width);
            [self.style setInnerWidth:_imageView.frame.size.width];
        }
        if(self.style.resizeHeight){
            NSLog(@"height: %f", _imageView.frame.size.height);
            [self.style setInnerHeight:_imageView.frame.size.height];
        }
        if(!self.style.resizeWidth && self.style.resizeHeight){
            // 等比缩放
            if(_imageView.frame.size.height != 0){
                CGFloat h = self.style.innerWidth / _imageView.frame.size.width * _imageView.frame.size.height;
                [self.style setInnerHeight:h];
            }
        }else if(self.style.resizeWidth && !self.style.resizeHeight){
            // 等比缩放
            if(_imageView.frame.size.width != 0){
                CGFloat w = self.style.innerHeight / _imageView.frame.size.height * _imageView.frame.size.width;
                [self.style setInnerWidth:w];
            }
        }
    }

    
    [super layout];
}

- (BOOL)highlightEvent{
    if (![self isOn]) {
        if (_hotImage) {
            [self.imageView setImage:_hotImage];
            [self setNeedsLayout];
        }
    }
    else{
        if (_selectedHotImage) {
            [self.imageView setImage:_selectedHotImage];
            [self setNeedsLayout];
        }
    }
    
    return YES;
}

- (void)fireChangeEvent{
    [self fireEvent:IEventChange];
}

- (void)addEvent:(IEventType)event handler:(void (^)(IEventType, IView *))handler {
    [super addEvent:event handler:handler];
    if(event & IEventChange){
        _changeHandler = handler;
    }
}

- (BOOL)fireEvent:(IEventType)event{
    if (event == IEventClick) {
        [super fireEvent:event];
        [self setOn: ![self isOn]];
        return YES;
    }
    if (event == IEventHighlight) {
        [super fireEvent:event];
        [self highlightEvent];
        return YES;
    }
    if(event == IEventChange && _changeHandler){
        _changeHandler(event, self);
        return YES;
    }
    return [super fireEvent:event];
}
@end
