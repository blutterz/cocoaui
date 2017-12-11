//
//  IHorTable.m
//  adVersion
//
//  Created by blutter on 2017/11/2.
//

#import "IHorTable.h"
#import "IHorCell.h"
#import "IStyleInternal.h"
#import "IViewInternal.h"

@interface IHorTable() <UIScrollViewDelegate>

@property(nonatomic, assign) NSUInteger visibleCellIndexMin;
@property(nonatomic, assign) NSUInteger visibleCellIndexMax;

@property(nonatomic, strong) ICell* possibleSelectedCell;
@property(nonatomic, strong) UIView* contentView;

@property(nonatomic, strong) NSMutableDictionary* tagViews;
@property(nonatomic, strong) NSMutableDictionary* tagClasses;

@property(nonatomic, assign) CGRect contentFrame;
@property(nonatomic, strong) NSMutableArray *cellSelectionEvents;

@property(nonatomic, assign) int fps;
@end

@implementation IHorTable

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cells = [[NSMutableArray alloc] init];
        _tagViews = [[NSMutableDictionary alloc] init];
        _tagClasses = [[NSMutableDictionary alloc] init];
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = [UIScreen mainScreen].bounds;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.scrollEnabled = YES;
        _scrollView.bounces = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentFrame.size.height = [UIScreen mainScreen].bounds.size.height;
        
        _visibleCellIndexMin = NSUIntegerMax;
        _visibleCellIndexMax = 0;
        
        [_scrollView addSubview:_contentView];
        _cellSelectionEvents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutViews];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self layoutViews];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) deviceOrientationDidChange:(NSNotification *) notification{
    if (!self.view.superview) {
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        _contentFrame.size.height = height;
        if (_scrollView.frame.size.height != height) {
            CGRect frame = _scrollView.frame;
            frame.size.height = height;
            _scrollView.frame = frame;
        }
        [self layoutViews];
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    _fps = MAX(1, (duration / 0.01));
    for (int i= 1; i< _fps; i++) {
        [self performSelector:@selector(func:) withObject:@(i) afterDelay:i * duration /_fps ];
    }
}

- (void) func:(NSNumber *)arg{
    int num = [arg intValue];
    if (num != _fps) {
        CGRect old_bounds = self.view.superview.bounds;
        CGRect bounds = self.view.superview.bounds;
        
        CGFloat height = self.view.layer.presentationLayer.bounds.size.height;
        
        if (_contentFrame.size.height != height) {
            bounds.size.height = height;
            self.view.superview.bounds = bounds;
            [self layoutViews];
            self.view.superview.bounds = old_bounds;
        }
    } else {
        _fps = 0;
        [self layoutViews];
    }
}

#pragma mark - datasource manipulating

- (void) clear {
    for (NSUInteger i = _visibleCellIndexMin; i<= _visibleCellIndexMax; i++) {
        IHorCell* cell = [_cells objectAtIndex:i];
        [cell.view removeFromSuperview];
        cell.view = nil;
        cell.contentView = nil;
    }
    
    [_cells removeAllObjects];
    _visibleCellIndexMin = NSUIntegerMax;
    _visibleCellIndexMax = 0;
    _contentFrame.size.width = 0;
    [self reload];
}

- (void) reload {
    [self layoutViews];
}

- (NSUInteger) count {
    return _cells.count;
}

- (void) scrollToRowAtIndex:(NSUInteger)index animated:(BOOL)animated {
    if (index >= _cells.count) {
        return;
    }
    
    IHorCell* cell = [_cells objectAtIndex:index];
    CGRect frame = CGRectMake(cell.x, 0, cell.width, _contentFrame.size.height);
    [self.scrollView scrollRectToVisible:frame animated:animated];
}

- (void) removeRowAtIndex:(NSUInteger)index {
    IHorCell* cell = [_cells objectAtIndex:index];
    if (!cell) {
        return;
    }
    
    cell.width = 0;
    [cell.view removeFromSuperview];
    cell.view = nil;
    cell.contentView = nil;
    [_cells removeObjectAtIndex:index];
}

- (void) registerViewClass:(Class)ivClass forTag:(NSString *)tag {
    [_tagClasses setObject:ivClass forKey:tag];
    
    NSMutableArray *views = [[NSMutableArray alloc] init];
    [_tagViews setObject:views forKey:tag];
}

- (void) addIViewRow:(IView *)view {
    [self insertIViewRow:view atIndex:_cells.count defaultWidth:view.style.outerWidth];
}

- (void) addIViewRow:(IView *)view defaultWidth:(CGFloat)width {
    [self insertIViewRow:view atIndex:_cells.count defaultWidth:width];
}

- (void) addDataRow:(id)data forTag:(NSString *)tag {
    [self insertDataRow:data forTag:tag atIndex:_cells.count];
}

- (void) addDataRow:(id)data forTag:(NSString *)tag defaultWidth:(CGFloat)width {
    [self insertDataRow:data forTag:tag atIndex:_cells.count defaultWidth:width];
}

- (void) prependIViewRow:(IView *)view {
    [self insertIViewRow:view atIndex:0 defaultWidth:view.style.outerWidth];
}

- (void) prependIViewRow:(IView *)view defaultWidth:(CGFloat)width {
    [self insertIViewRow:view atIndex:0 defaultWidth:width];
}

- (void) prependDataRow:(id)data forTag:(NSString *)tag {
    [self insertDataRow:data forTag:tag atIndex:0];
}

- (void) prependDataRow:(id)data forTag:(NSString *)tag defaultWidth:(CGFloat)width{
    [self insertDataRow:data forTag:tag atIndex:0 defaultWidth:width];
}

- (void) updateIViewRow:(IView *)view atIndex:(NSUInteger)index {
    IHorCell* cell = [_cells objectAtIndex:index];
    if (!cell) {
        return;
    }
    cell.contentView = view;
}

- (void) updateDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index {
    IHorCell* cell = [_cells objectAtIndex:index];
    if (!cell) {
        return;
    }
    cell.tag = tag;
    cell.data = data;
    [cell.contentView setDataInternal:cell.data];
    cell.contentView.data = cell.data;
}

- (void) insertIViewRow:(IView *)view atIndex:(NSUInteger)index {
    [self insertIViewRow:view atIndex:index defaultWidth:90];
}

- (void) insertIViewRow:(IView *)view atIndex:(NSUInteger)index defaultWidth:(CGFloat)width {
    IHorCell* cell = [[IHorCell alloc] init];
    cell.contentView = view;
    [self insertCell:cell atIndex:index defaultWidth:width];
}

- (void) insertDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index {
    [self insertDataRow:data forTag:tag atIndex:index defaultWidth:90];
}

- (void) insertDataRow:(id)data forTag:(NSString *)tag atIndex:(NSUInteger)index defaultWidth:(CGFloat)width {
    IHorCell* cell = [[IHorCell alloc] init];
    cell.tag = tag;
    cell.data = data;
    [self insertCell:cell atIndex:index defaultWidth:width];
}

- (void) insertCell:(IHorCell *)cell atIndex:(NSUInteger)index defaultWidth:(CGFloat)width {
    cell.width = width;
    cell.table = self;
    [_cells insertObject:cell atIndex:index];
    
    IHorCell* prev = nil;
    if (index > 0) {
        prev = [_cells objectAtIndex:index -1];
    }
    
    for(NSUInteger i=index; i<_cells.count; i++){
        IHorCell *cell = [_cells objectAtIndex:i];
        if(!prev){
            cell.x = 0;
        }else{
            cell.x = prev.x + prev.width;
        }
        prev = cell;
    }
    
    _contentFrame.size.width += cell.width;
    
    if (_cells.count > 1 && index <= _visibleCellIndexMin ) {
        CGPoint offset = _scrollView.contentOffset;
        offset.x += cell.width;
        _scrollView.contentOffset = offset;
    }
}

- (void) addDivider:(NSString *)css {
    [self addDivider:css width:15];
}

- (void) addDivider:(NSString *)css width:(CGFloat)width {
    IView* view = [[IView alloc] init];
    [view.style set:[NSString stringWithFormat:@"width: %f; background: #efeff4;" ,width]];
    [view.style set:css];
    IHorCell* cell = [[IHorCell alloc] init];
    cell.isSeparator = YES;
    cell.contentView = view;
    [self insertCell:cell atIndex:_cells.count defaultWidth:view.style.outerWidth];
}

#pragma mark - layout views

- (void) cell:(IHorCell *)cell didResizeWidthDelta:(CGFloat)delta {
    NSUInteger index = [_cells indexOfObject:cell];
    _contentFrame.size.width  += delta;
    
    for (NSUInteger i = index; i < _cells.count;  i++) {
        IHorCell* cell = [_cells objectAtIndex:i];
        if ( i != index ) {
            cell.x  += delta;
        }
    }
    [self layoutViews];
}

- (void) addVisibleCellAtIndex:(NSUInteger)index {
    IHorCell *cell = [self cellForRowAtIndex:index];
    [_contentView addSubview:cell.view];
}

- (void)removeVisibleCellAtIndex:(NSUInteger)index {
    if (index >= _cells.count) {
        return;
    }
    
    IHorCell* cell = [_cells objectAtIndex:index];
    if (cell.contentView) {
        [cell.contentView setDataInternal:nil];
        cell.contentView.cell = nil;
    }
    
    if (cell.view) {
        [cell.view removeFromSuperview];
    }
    
    if (cell.tag) {
        NSMutableArray* views = [_tagViews objectForKey:cell.tag];
        if (views.count < 3 && views) {
            [views addObject:cell.view];
        }
        cell.contentView = nil;
        cell.view = nil;
    }
}

- (IHorCell *)cellForRowAtIndex:(NSUInteger)index {
    IHorCell *cell = [_cells objectAtIndex:index];
    if (!cell.view) {
        if (cell.tag) {
            NSMutableArray* views = [_tagViews objectForKey:cell.tag];
            if (views.count > 0) {
                cell.view = views.lastObject;
                [views removeLastObject];
                cell.contentView = [cell.view.subviews objectAtIndex:0];
                [cell.contentView setNeedsLayout];
            } else {
                cell.view = [[IHorCellView alloc] init];
                Class cls = [_tagClasses objectForKey:cell.tag];
                if (cls) {
                    cell.contentView = [[cls alloc] init];
                    [cell.contentView.style set:@"height:100%;"];
                    [cell.view addSubview:cell.contentView];
                }
            }
        } else {
            cell.view = [[IHorCellView alloc] init];
            if (cell.contentView) {
                [cell.contentView.style set:@"height:100%;"];
                [cell.view addSubview:cell.contentView];
            }
        }
    }
    cell.view.cell = cell;
    if (cell.contentView) {
        cell.contentView.horCell = cell;
    }
    return cell;
}

- (void) layoutViews{
    _contentFrame.origin.x = 0;
    if (self.view.superview) {
        if (!CGSizeEqualToSize(_scrollView.frame.size, self.view.frame.size)) {
            log_debug(@"change size, w: %.1f=>%.1f, h: %.1f=>%.1f", _scrollView.frame.size.width, self.view.frame.size.width, _scrollView.frame.size.height, self.view.frame.size.height);
            
            CGRect frame = _scrollView.frame;
            frame.size = self.view.frame.size;
            _scrollView.frame = frame;
            _contentFrame.size.height = self.view.frame.size.height;
        }
    }
    
    _contentView.frame = _contentFrame;
    CGSize scrollSize = _contentFrame.size;
    _scrollView.contentSize = scrollSize;
    
    [self constructVisibleCells];
    
    [UIView setAnimationsEnabled:NO];
    [self layoutVisibleCells];
    [UIView setAnimationsEnabled:YES];
    
}

- (void) layoutVisibleCells{
    for (NSUInteger i=_visibleCellIndexMin; i<=_visibleCellIndexMax; i++) {
        IHorCell *cell = [_cells objectAtIndex:i];
        CGRect old_frame = cell.view.frame;
        CGRect frame = CGRectMake(cell.x, cell.y, cell.width, _scrollView.contentSize.height);
        if (cell.contentView && !CGRectEqualToRect(old_frame, frame)) {
            cell.view.frame = frame;
            [cell.contentView setNeedsLayout];
        }
        
        if (cell.data && cell.contentView && !cell.contentView.data) {
            [cell.contentView setDataInternal:cell.data];
            cell.contentView.data = cell.data;
        }
        
//        if (cell.contentView && cell.contentView.style.ratioWidth > 0) {
//            CGRect frame = cell.view.frame;
//
//            frame.size.width = cell.table.view.frame.size.width;
//            if (cell.view.frame.size.width != frame.size.width) {
//                cell.view.frame = frame;
//                [cell.contentView setNeedsLayout];
//                log_debug(@"%.1f=>%.1f", cell.width, frame.size.width);
//            }
//        }
    }
}

- (void) constructVisibleCells{
    CGFloat visibleWidth = _scrollView.frame.size.width - _scrollView.contentInset.left;
    CGFloat minVisibleX = _scrollView.contentOffset.x + _scrollView.contentInset.left - _contentView.frame.origin.x;
    CGFloat maxVisibleX = minVisibleX + visibleWidth;
    
    //log_debug(@"%.1f ==> visible: %.1f, min: %.1f, max: %.1f",_scrollView.frame.size.width, visibleWidth, minVisibleX, maxVisibleX);
    
    NSUInteger minIndex = NSUIntegerMax;
    NSUInteger maxIndex = 0;
    
    for (NSUInteger i= 0; i < _cells.count; i++) {
        IHorCell* cell = [_cells objectAtIndex:i];
        CGFloat min_x = cell.x;
        CGFloat max_x = min_x + cell.width;
        
        if (min_x > maxVisibleX) {
            break;
        }
        
        if (max_x < minVisibleX) {
            //TODO
        } else {
            minIndex = MIN(minIndex, i);
            maxIndex = MAX(maxIndex, i);
        }
    }
    
    if (_visibleCellIndexMin == minIndex && _visibleCellIndexMax == maxIndex) {
        return; //No need layout
    }
    
    NSUInteger low = MIN(minIndex, _visibleCellIndexMin);
    NSUInteger high = MAX(maxIndex, _visibleCellIndexMax);
    
    for (NSUInteger index = low; index <= high; index++) {
        if (index >= _cells.count) {
            break;
        }
        
        IHorCell* cell = [_cells objectAtIndex:index];
        if (index < minIndex || index > maxIndex) {
            if (cell.view.superview) {
                [self removeVisibleCellAtIndex:index];
            }
        } else {
            if (!cell.view.superview) {
                [self addVisibleCellAtIndex:index];
            }
        }
    }
    _visibleCellIndexMin = minIndex;
    _visibleCellIndexMax = maxIndex;
}

#pragma mark -- UIScrollViewDelegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self layoutViews];
}

#pragma mark - Event hanlders
- (void) onHighlight:(IView *)view atIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(table:onHighlight:atIndex:)]) {
        [_delegate table:self onHighlight:view atIndex:index];
    }
}

- (void) onUnhighlight:(IView *)view atIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(table:onUnhighlight:atIndex:)]) {
        [_delegate table:self onUnhighlight:view atIndex:index];
    }
}

- (void) onClick:(IView *)view atIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(table:onClick:atIndex:)]) {
        [_delegate table:self onClick:view atIndex:index];
    }
}

#pragma block

- (void) foreachViewsWithoutIndex:(NSUInteger)index block:(void (^)(IView *, id data))block {
    for (IHorCell* cell in _cells) {
        if (cell.index != index) {
            block(cell.contentView, cell.data);
        }
    }
}
@end
