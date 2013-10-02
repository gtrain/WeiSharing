//
//  PanelView.m
//  鼠标测试
//
//  Created by yang on 13-1-23.
//  Copyright (c) 2013年 yang. All rights reserved.
//
/*
 不将其直接绘制到屏幕的原因是可能会擦除之前绘制过的路径，所以需要一个图像来保存。
 此外，在用NSBezierPath来绘图时，需要lockFocus图像，否则不会绘制到图像里。
 而在接收鼠标事件时，mouseDown只需要记录lastLocation和画点，mouseDragged需要连线，mouseUp则清除图像。
 */

#import "PanelView.h"

@implementation PanelView

#pragma mark ----view lifecycle----

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        customMouse=[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"cursor"] hotSpot:NSMakePoint(12,12)];  //鼠标样式
        [customMouse set];
    }
    return self;
}

#pragma mark ----鼠标监听----
- (void)mouseDown:(NSEvent *)event {
    AppDelegate *appdelegate=(AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appdelegate.window setIsVisible:NO];
    mouseDownPoint=[event locationInWindow];//[self convertPoint:self.window.mouseLocationOutsideOfEventStream fromView:nil];
}

- (void)mouseDragged:(NSEvent *)event
{
    [customMouse set];
    NSPoint mouseMovePoint=[event locationInWindow];
	if(mouseMovePoint.x!=mouseDownPoint.x || mouseMovePoint.y!=mouseDownPoint.y){
		snapshotRect=[self getRectWithPoint:mouseDownPoint endIn:mouseMovePoint];
    }
	[self display]; //display后，系统会自动用drawRect（绘制框框）[self setNeedsDisplay:YES];  rect不能为0
}

- (void)drawRect:(NSRect)dirtyRect
{
    if(snapshotRect.size.width>0 && snapshotRect.size.height>0){
        NSBezierPath *marquee=[NSBezierPath bezierPathWithRect:snapshotRect];
        const double dashArray[2] = {6.0, 2.0};
        [marquee setLineDash:dashArray count:sizeof(dashArray) / sizeof(dashArray[0]) phase:0.0];
        [[NSColor colorWithCalibratedWhite:0.2 alpha:0.4] setStroke];
        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.4] setFill];
        [marquee setLineJoinStyle:NSMiterLineJoinStyle];
        [marquee fill];
        [marquee stroke];
    }
}

- (void)mouseUp:(NSEvent *)event
{
    //    NSLog(@"起始点：(%f,%f)",mouseDownPoint.x,mouseDownPoint.y);
    //    NSLog(@"结束点：(%f,%f)",mouseUpPoint.x,mouseUpPoint.y);
    mouseUpPoint=[event locationInWindow];

    if(mouseUpPoint.x!=mouseDownPoint.x || mouseUpPoint.y!=mouseDownPoint.y){
        snapshotRect=[self getRectWithPoint:mouseDownPoint endIn:mouseUpPoint];
        snapshotRect.origin.y=NSScreen.mainScreen.frame.size.height-snapshotRect.origin.y-snapshotRect.size.height;
        //截图坐标是从左上角开始，而window是从左下角开始，所以这里做一下处理
        
        NSValue *rectValue=[NSValue valueWithRect:snapshotRect];
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:rectValue,SCREENSHOTRECT,nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_GET_SNAPSHOT object:nil userInfo:userInfo];
        //通知NotificationCenter，已经获取到rect，注册者（appdelegate将会接受并关闭该window）
    }
}

//重置鼠标样式
-(void) resetCursorRects{
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:customMouse];
}

//根据两点获取矩形Rect
-(NSRect) getRectWithPoint:(NSPoint)startPoint endIn:(NSPoint)endPoint{
    float ax=startPoint.x<endPoint.x?startPoint.x:endPoint.x;
    float ay=startPoint.y<endPoint.y?startPoint.y:endPoint.y;
    float aw=fabs(startPoint.x-endPoint.x);
    float ah=fabs(startPoint.y-endPoint.y);
    return NSMakeRect(ax, ay, aw, ah);
}

@end
