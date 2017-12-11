/*
 Copyright (c) 2017 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.

 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ISelectDemo.h"

@interface ISelectDemo (){
}
@end

@implementation ISelectDemo

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"ISelectDemo";

	IView *view = [IView namedView:@"ISelectDemo"];
	[self addIViewRow:view];
	
	// https://github.com/ideawu/cocoaui/issues/67
	__weak typeof(self) me = self;
	IButton *btn = (IButton *)[view getViewById:@"toggle"];
	[btn bindEvent:IEventClick handler:^(IEventType event, IView *view) {
		[me.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
	}];
}

@end
