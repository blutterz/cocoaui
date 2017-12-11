//
//  IHorCellView.m
//  CocoaUI
//
//  Created by blutter on 2017/11/3.
//

#import "IHorCellView.h"
#import "IHorCell.h"
#import "IHorTable.h"

@implementation IHorCellView

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [_cell.table onHighlight:_cell.contentView atIndex:_cell.index];
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [_cell.table onClick:_cell.contentView atIndex:_cell.index];
    [self performSelector:@selector(delayUnhighlight) withObject:nil afterDelay:0.15];
}

- (void) delayUnhighlight {
    [_cell.table onUnhighlight:_cell.contentView atIndex:_cell.index];
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [_cell.table onUnhighlight:_cell.contentView atIndex:_cell.index];
}
@end
