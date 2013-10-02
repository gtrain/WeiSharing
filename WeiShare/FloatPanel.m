//
//  FloatPanel.m
//  鼠标测试
//
//  Created by yang on 13-1-23.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#import "FloatPanel.h"

@implementation FloatPanel
-(id) initWithContentRect:(NSRect)contentRect{
    self=[super initWithContentRect:contentRect
                          styleMask:(NSBorderlessWindowMask | NSNonactivatingPanelMask)
                            backing:NSBackingStoreBuffered
                              defer:NO];
    if (self) {
        self.backgroundColor=NSColor.clearColor;
        self.level=CGShieldingWindowLevel();
        
        //非当前窗口也处于激活状态，飞逝第一次点击会被当成选中窗口
        self.opaque=NO;
        self.hasShadow=NO;
        self.hidesOnDeactivate=NO;
    }
    return self;
}


@end
