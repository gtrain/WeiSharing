//
//  PanelView.h
//  鼠标测试
//
//  Created by yang on 13-1-23.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface PanelView : NSView{
    NSPoint mouseDownPoint; //选取的起始点
    NSPoint mouseUpPoint;   //选取的结束点

    NSRect snapshotRect;    //选取的框架
    
    NSCursor *customMouse;  //鼠标样式
}

-(void) resetCursorRects;

@end
