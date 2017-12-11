//
//  IHorCell.m
//  adVersion
//
//  Created by blutter on 2017/11/3.
//

#import "IHorCell.h"
#import "IView.h"
#import "IHorTable.h"

@interface IHorTable()

- (void)cell:(IHorCell *)cell didResizeWidthDelta:(CGFloat)delta;

@end

@implementation IHorCell

- (void) setWidth:(CGFloat)width {
    if (_width != width) {
        if (_table) {
            CGFloat  dalta = width - _width;
            _width = width;
            [_table cell:self didResizeWidthDelta:dalta];
        } else {
            _width = width;
        }
    }
    else {
        log_debug(@"%.1f %.1f", width, _width);
    }
}

- (NSUInteger) index{
    if (_table) {
        return [_table.cells indexOfObject:self];
    } else {
        return NSNotFound;
    }
}
@end
