//
//  FloatPanel.h
//  鼠标测试
//
//  Created by yang on 13-1-23.
//  Copyright (c) 2013年 yang. All rights reserved.
//  定制一个窗口类，去除边框和阴影，背景色透明，level最高

#import <Cocoa/Cocoa.h>

@interface FloatPanel : NSPanel

-(id) initWithContentRect:(NSRect)contentRect;

@end
