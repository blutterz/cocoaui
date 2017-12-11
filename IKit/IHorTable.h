//
//  IHorTable.h
//  adVersion
//
//  Created by blutter on 2017/11/2.
//
#ifndef IKit_Hor_ITable_h
#define IKit_Hor_ITable_h

#import "IView.h"

@class IHorTable;

@protocol IHorTableDelegate<NSObject>
@optional
- (void)table:(IHorTable *)table onHighlight:(IView *)view atIndex:(NSUInteger)index;
- (void)table:(IHorTable *)table onUnhighlight:(IView *)view atIndex:(NSUInteger)index;
- (void)table:(IHorTable *)table onClick:(IView *)view atIndex:(NSUInteger)index;
@end

@interface IHorTable : UIViewController

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, weak) id<IHorTableDelegate> delegate;

- (void) clear;
- (void) reload;
- (NSUInteger) count;

- (void) scrollToRowAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void) removeRowAtIndex:(NSUInteger)index;

- (void) registerViewClass:(Class)ivClass forTag:(NSString*)tag;

- (void) addIViewRow:(IView *)view;
- (void) addIViewRow:(IView *)view defaultWidth:(CGFloat)width;
- (void) addDataRow:(id)data forTag:(NSString *)tag;
- (void) addDataRow:(id)data forTag:(NSString *)tag defaultWidth:(CGFloat)width;

- (void) prependIViewRow:(IView *)view;
- (void) prependIViewRow:(IView *)view defaultWidth:(CGFloat)width;
- (void) prependDataRow:(id)data forTag:(NSString *)tag;
- (void) prependDataRow:(id)data forTag:(NSString *)tag defaultWidth:(CGFloat)width;

- (void) updateIViewRow:(IView *)view atIndex:(NSUInteger)index;
- (void) updateDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index;

- (void) insertIViewRow:(IView *)view atIndex:(NSUInteger)index;
- (void) insertIViewRow:(IView *)view atIndex:(NSUInteger)index defaultWidth:(CGFloat)width;
- (void) insertDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index;
- (void) insertDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index defaultWidth:(CGFloat)width;

- (void) addDivider:(NSString *)css;
- (void) addDivider:(NSString *)css width:(CGFloat)width;

- (void) foreachViewsWithoutIndex:(NSUInteger)index block:(void (^)(IView* view, id data))block;

////////////////// event callbacks /////////////////////
- (void) onHighlight:(IView *)view atIndex:(NSUInteger)index;
- (void) onUnhighlight:(IView *)view atIndex:(NSUInteger)index;
- (void) onClick:(IView *)view atIndex:(NSUInteger)index;

@end

#endif
