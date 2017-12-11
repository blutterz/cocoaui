//
//  IHorCell.h
//  adVersion
//
//  Created by blutter on 2017/11/3.
//

#import <UIKit/UIKit.h>
#import "IHorCellView.h"

@class IView;
@class IHorTable;

@interface IHorCell : NSObject

@property (nonatomic, weak) IHorTable *table;

@property (nonatomic) IHorCellView *view;
@property (nonatomic) IView *contentView;

@property (nonatomic) BOOL isSeparator;

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat width;

@property (nonatomic) NSString *tag;
@property (nonatomic) id data;

- (NSUInteger)index;

@end
