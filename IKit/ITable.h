/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_ITable_h
#define IKit_ITable_h

#import <UIKit/UIKit.h>
#import "IView.h"

@class IPullRefresh;
@class IRefreshControl;
@class ITable;

/*
 ITable
	 _tableView
		 _scrollView
			 _headerRefreshWrapper
				_headerRefreshControl
			 ------------------visible top------------------
			 _headerView(position: auto-docked)
			 _contentView(_contentFrame)
				cells
			 _footerView
			 _footerRefreshControl
		 _bottomBar(position: fixed)

 */


@protocol ITableDelegate <NSObject>
@optional
- (void)table:(ITable *)table onHighlight:(IView *)view atIndex:(NSUInteger)index;
- (void)table:(ITable *)table onUnhighlight:(IView *)view atIndex:(NSUInteger)index;
- (void)table:(ITable *)table onClick:(IView *)view atIndex:(NSUInteger)index;
/**
 * Must call ITable.endRefresh() when state is IRefreshBegin
 */
- (void)table:(ITable *)table onRefresh:(IRefreshControl *)view state:(IRefreshState)state;
@end


@class ITable;

@interface ITable : UIViewController

@property (nonatomic) IRefreshControl *headerRefreshControl;
@property (nonatomic) IRefreshControl *footerRefreshControl;

/**
 * At the top of contents(cells), and only follow pull down to refresh.
 */
@property (nonatomic) IView *headerView;
/**
 * At the bottom of contents(cells) and follow scroll.
 */
@property (nonatomic) IView *footerView;
@property (nonatomic) UIScrollView *scrollView;

/**
 * Will dock at the bottom and will not scroll.
 */
@property (nonatomic) IView *bottomBar;

- (void)clear;
- (void)reload;
- (NSUInteger)count;


- (void)scrollToRowAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)removeRowAtIndex:(NSUInteger)index;
- (void)removeRowAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeRowContainsUIView:(UIView *)view;
- (void)removeRowContainsUIView:(UIView *)view animated:(BOOL)animated;

- (void)registerViewClass:(Class)ivClass forTag:(NSString *)tag;

- (void)addIViewRow:(IView *)view;
- (void)addIViewRow:(IView *)view defaultHeight:(CGFloat)height;
- (void)addDataRow:(id)data forTag:(NSString *)tag;
- (void)addDataRow:(id)data forTag:(NSString *)tag defaultHeight:(CGFloat)height;

- (void)prependIViewRow:(IView *)view;
- (void)prependIViewRow:(IView *)view defaultHeight:(CGFloat)height;
- (void)prependDataRow:(id)data forTag:(NSString *)tag;
- (void)prependDataRow:(id)data forTag:(NSString *)tag defaultHeight:(CGFloat)height;

- (void)updateIViewRow:(IView *)view atIndex:(NSUInteger)index;
- (void)updateDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index;

- (void)insertIViewRow:(IView *)view atIndex:(NSUInteger)index;
- (void)insertIViewRow:(IView *)view atIndex:(NSUInteger)index defaultHeight:(CGFloat)height;
- (void)insertDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index;
- (void)insertDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index defaultHeight:(CGFloat)height;

- (void)addDivider:(NSString *)css;
- (void)addDivider:(NSString *)css height:(CGFloat)height;

////////////////// event callbacks /////////////////////
/*
 Sub class of ITable should implement event callbacks.
 */

- (void)onHighlight:(IView *)view atIndex:(NSUInteger)index;
- (void)onUnhighlight:(IView *)view atIndex:(NSUInteger)index;
- (void)onClick:(IView *)view atIndex:(NSUInteger)index;

/**
 Implement this method to accept Pull Refresh events, no need to call [super xxx].
 Must call refreshControl.endRefresh() when state is IRefreshBegin.
 */
- (void)onRefresh:(IRefreshControl *)refreshControl state:(IRefreshState)state;
/// @deprecated: Use IRefreshControl.beginRefresh instead
- (void)beginRefresh:(IRefreshControl *)refreshControl;
/// @deprecated: Use IRefreshControl.endRefresh instead
- (void)endRefresh:(IRefreshControl *)refreshControl;

/**
 UIViews wrapping ITable.view should provide delegate.
 */
@property (nonatomic, weak) id<ITableDelegate> delegate;

////////////////////////////////////////////////////////

// @deprecated, use addDivider instead
- (void)addSeparator:(NSString *)css;
- (void)addSeparator:(NSString *)css height:(CGFloat)height;

// @deprecated
- (void)onHighlight:(IView *)view;
- (void)onUnhighlight:(IView *)view;
- (void)onClick:(IView *)view;


@end

#endif
