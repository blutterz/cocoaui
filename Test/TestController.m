/*
 Copyright (c) 2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.

 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "TestController.h"

@interface TestController ()

@end

@implementation TestController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = @"Test";

	IView *view = [IView namedView:@"Test"];
	[self addIViewRow:view];
    
    IOption * op = (IOption*)[view getViewById:@"opt1"];
    [op addEvent:IEventChange handler:^(IEventType event, IView *view) {
        NSLog(@">>>>>>");
    }];
}

@end
