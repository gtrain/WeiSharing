//
//  OAuthWebView.h
//  OA_Test
//
//  Created by yang on 13-1-23.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "Global.h"

@interface OAuthWebView : NSWindowController

@property (assign) IBOutlet WebView *webView;

//使用协议拦截回调网站的跳转，并获取字符串
- (NSURLRequest *)webView:(WebView *)sender
                 resource:(id)identifier
          willSendRequest:(NSURLRequest *)request
         redirectResponse:(NSURLResponse *)redirectResponse
           fromDataSource:(WebDataSource *)dataSource;
@property (strong) NSURL *requestUrl;

@end
