//
//  OAuthWebView.m
//  OA_Test
//
//  Created by yang on 13-1-23.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#import "OAuthWebView.h"

@interface OAuthWebView ()

@end

@implementation OAuthWebView
@synthesize webView;

#pragma mark --view lifecycle--
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    //发送请求
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:self.requestUrl]];
    self.window.title=@"正在载入,情稍后..";
}

#pragma mark ----WebResourceLoadDelegate----
//使用协议拦截回调网站的跳转，并获取字符串
- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request
         redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource{
    NSString *url = request.URL.absoluteString;
    //NSLog(@"url = %@", url);
    
    //如果请求包含回调前缀
	if ([url hasPrefix:kAppRedirectURI]) {
        //如果包含error代码
        NSString *error_code = [self getParamValueFromUrl:url paramName:@"error_code"];
        if (error_code)
        {
            NSString *error = [self getParamValueFromUrl:url paramName:@"error"];
            NSString *error_uri = [self getParamValueFromUrl:url paramName:@"error_uri"];
            NSString *error_description = [self getParamValueFromUrl:url paramName:@"error_description"];
            
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       error, @"error",
                                       error_uri, @"error_uri",
                                       error_code, @"error_code",
                                       error_description, @"error_description", nil];
            NSLog(@"errorInfo:%@",errorInfo);
            [self.window close];
            //[delegate authorizeView:self didFailWithErrorInfo:errorInfo];
        }
        else
        {   //认证通过，截获code码
            NSString *code = [self getParamValueFromUrl:url paramName:@"code"];
            if (code)
            {
                NSLog(@"code:%@",code);
                //保存code,post上通知中心.关闭窗口
                [[NSUserDefaults standardUserDefaults] setObject:code forKey:USER_STORE_CODE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:DID_GET_CODE object:nil];
                [self.window close];
            }
        }
		return nil;
	}
    return request;
}
-(NSString *)getParamValueFromUrl:(NSString*)url paramName:(NSString *)paramName
{
    if (![paramName hasSuffix:@"="]) //给参数名加上=号
    {
        paramName = [NSString stringWithFormat:@"%@=", paramName];
    }
    
    NSString * str = nil;
    NSRange start = [url rangeOfString:paramName];
    if (start.location != NSNotFound)
    {
        // confirm that the parameter is not a partial name match
        unichar c = '?';
        if (start.location != 0)
        {
            c = [url characterAtIndex:start.location - 1];
        }
        if (c == '?' || c == '&' || c == '#')
        {
            NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
            NSUInteger offset = start.location+start.length;
            str = end.location == NSNotFound ?
            [url substringFromIndex:offset] :
            [url substringWithRange:NSMakeRange(offset, end.location)];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return str;
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource{
    self.window.title=@"应用授权";
}

//- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource{
//    NSLog(@"收到数据， request：%@ ",[dataSource.request URL]);
//}






//剥离出url中的access_token的值
/*- (void) dialogDidSucceed:(NSURL*)url {
    NSString *q = [url absoluteString];
    NSString *token = [self getStringFromUrl:q needle:@"access_token="];
    NSString *refreshToken  = [self getStringFromUrl:q needle:@"refresh_token="];
    NSString *expTime       = [self getStringFromUrl:q needle:@"expires_in="];
    NSString *uid           = [self getStringFromUrl:q needle:@"uid="];
    NSString *remindIn      = [self getStringFromUrl:q needle:@"remind_in="];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:USER_STORE_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:USER_STORE_USER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
        
    NSDate *expirationDate =nil;
    NSLog(@"截取成功");
    NSLog(@"jtone \n\ntoken=%@\nrefreshToken=%@\nexpTime=%@\nuid=%@\nremindIn=%@\n\n",token,refreshToken,expTime,uid,remindIn);
    if (expTime != nil) {
        int expVal = [expTime intValue]-3600;
        if (expVal == 0)
        {
            
        } else {
            expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
            [[NSUserDefaults standardUserDefaults]setObject:expirationDate forKey:USER_STORE_EXPIRATION_DATE];
            [[NSUserDefaults standardUserDefaults] synchronize];
			NSLog(@"jtone time = %@",expirationDate);
        }
    }
    if (token) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_GET_TOKEN_IN_WEB_VIEW object:nil];
        [self.window close];
    }
}
*/

@end