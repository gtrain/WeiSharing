//
//  AppDelegate.m
//  WeiShare
//
//  Created by yang on 13-1-22.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize weiboLink;
@synthesize LoginBtn;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObject:self];
    self.window=nil;
    self.accessToken=nil;   //清空用户数据,本地数据再另一个页面删除
    self.userID=nil;
    self.expirationDate=nil;
    self.networkQueue=nil;
    
    [screenShotWindow release];
    screenShotWindow=nil;
    
    free(displays);
    displays=nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //[self.window setMinSize:CGSizeMake(10, 10)];  //min跟max设置相同，禁止放大
    //[self.window setMaxSize:CGSizeMake(10, 10)];
    displays = nil;
    tmp_request=nil;
    weiboURL=nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTokenByCode) name:DID_GET_CODE object:nil];
    //注册认证成功通知，（token存在default plist里面了 ）DID_GET_SNAPSHOT
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(snapshotRectFinash:) name:DID_GET_SNAPSHOT object:nil];
    //注册截图完成通知，需要rect信息
    [self interrogateHardware];     //初始化display数组
    [self netWorkInit];     //初始化网络连接

    //初始化OAuth数据
    self.accessToken=[[NSUserDefaults standardUserDefaults] objectForKey:USER_STORE_ACCESS_TOKEN];
    self.userID=[[NSUserDefaults standardUserDefaults] objectForKey:USER_STORE_USER_ID];
    self.expirationDate=[[NSUserDefaults standardUserDefaults] objectForKey:USER_STORE_EXPIRATION_DATE];
    
    [self getUserInfoByToken];
}

-(void) netWorkInit{
    self.networkQueue=[ASINetworkQueue queue];      //获得网络队列实例
    self.networkQueue.showAccurateProgress=YES;     //精确的进度
    self.networkQueue.shouldCancelAllRequestsOnFailure=NO;
    
    //队列要处理  ASIHTTPRequest的Delegate
    self.networkQueue.downloadProgressDelegate=self;//下载进程的代理
    self.networkQueue.delegate=self;                //代理
    
    self.networkQueue.requestDidStartSelector=@selector(requestStartedByQueue:);
    //self.networkQueue.requestDidReceiveResponseHeadersSelector=@selector(requestReceivedResponseHeaders:);
    self.networkQueue.requestDidFinishSelector=@selector(requestFinishedByQueue:);
    self.networkQueue.requestDidFailSelector=@selector(requestFailedByQueue:);
    self.networkQueue.queueDidFinishSelector=@selector(queueFinished:);
    
    //设置完成，启动队列
    [self.networkQueue go];
}


#pragma mark ----微博登陆功能----
- (IBAction)userLogin:(NSButton *)sender {
    //清空原有数据
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* sinaweiboCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://open.weibo.cn"]];
    for (NSHTTPCookie* cookie in sinaweiboCookies)
    {
        [cookies deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_STORE_CODE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_STORE_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_STORE_USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_STORE_EXPIRATION_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.accessToken=nil;   //清空用户数据,本地数据再另一个页面删除
    self.userID=nil;
    self.expirationDate=nil;
    
    self.weiboLink.title=@"";
    weiboURL=nil;
    
    if ([sender.title isEqualToString:@"注销"] || [sender.title isEqualToString:@"登陆中..."] ) {
        self.LoginBtn.title=@"登陆";
        return;
    }
    
    if ([self.LoginBtn.title isEqualToString:@"登陆"]) {
        //初始化web窗口，传入请求
        OAuthWebView *oaWebView=[[OAuthWebView alloc] initWithWindowNibName:@"OAuthWebView"];
        NSDictionary *authParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    kAppKey, @"client_id",
                                    @"code", @"response_type",
                                    kAppRedirectURI, @"redirect_uri",
                                    @"mobile", @"display", nil];
        oaWebView.requestUrl =[self serializeURL:kSinaWeiboWebAuthURL params:authParams httpMethod:@"GET"];
        
        [oaWebView showWindow:sender];
        [oaWebView.window center];
    }
}


-(void) getTokenByCode{
   NSString *code =[[NSUserDefaults standardUserDefaults] objectForKey:USER_STORE_CODE];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            kAppKey, @"client_id",
                            kAppSecret, @"client_secret",
                            @"authorization_code", @"grant_type",
                            kAppRedirectURI, @"redirect_uri",
                            code, @"code", nil];
    NSURL* url = [self serializeURL:kSinaWeiboWebAccessTokenURL params:params httpMethod:@"POST"];
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    request.tag=1;
    [self.networkQueue addOperation:request];
    [request release];
}

-(void) getUserInfoByToken{
    if (_accessToken && _userID) {
        self.LoginBtn.title=@"登陆中...";
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                _userID, @"uid",
                                _accessToken, @"access_token", nil];
        NSURL* url = [self serializeURL:kSinaWeiboUserInfo params:params httpMethod:@"GET"];
        ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:url];
        [request setRequestMethod:@"GET"];
        request.tag=2;
        [self.networkQueue addOperation:request];
        [request release];
    }
}

//根据API跟参数组合url字符串
-(NSURL *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    NSURL* parsedURL = [NSURL URLWithString:baseURL];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator])
    {
        NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL, /* allocator */
                                                                                      (CFStringRef)[params objectForKey:key],
                                                                                      NULL, /* charactersToLeaveUnescaped */
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        [escaped_value release];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query]];
}

#pragma mark ----截图分享功能----

//apple文件的部分代码，用于获取当前的活动窗体数组
- (IBAction)OpenLink:(id)sender {
    if (weiboURL!=nil) {
        [[NSWorkspace sharedWorkspace] openURL:weiboURL];
    }
}

-(void)interrogateHardware
{
	CGError	err = CGDisplayNoErr;
	CGDisplayCount	dspCount = 0;
    /* How many active displays do we have? */
    err = CGGetActiveDisplayList(0, NULL, &dspCount);
	/* If we are getting an error here then their won't be much to display. */
    if(err != CGDisplayNoErr)
    {
        return;
    }
	/* Maybe this isn't the first time though this function. */
	if(displays != nil)
    {
		free(displays);
    }
	/* Allocate enough memory to hold all the display IDs we have. */
    displays = calloc((size_t)dspCount, sizeof(CGDirectDisplayID));
}

//截图按钮响应事件
- (IBAction)shotBtnPress:(NSButton *)sender {
    NSRect frame = NSScreen.mainScreen.frame;                   //获取屏幕尺寸
    screenShotWindow = [[FloatPanel alloc] initWithContentRect:frame];   //用自定义类更改窗体为透明
    NSView *view = [[PanelView alloc] initWithFrame:frame];     //再窗体上新建一个view进行绘制
    screenShotWindow.contentView = view;
    [view release];
    screenShotWindow.ignoresMouseEvents = NO;        //响应鼠标事件
    [screenShotWindow makeKeyAndOrderFront:nil];     //让窗口处于顶层
    [screenShotWindow resetCursorRects];
    //[_window setIsVisible:NO];
}

//收到截图完成通知后，关闭截图window,截图,启动分享窗口
-(void) snapshotRectFinash:(NSNotification *) notify{
    [screenShotWindow setIsVisible:NO];           //收到截图信息了，隐藏截图windows
    
    CGRect rect=[[notify.userInfo objectForKey:SCREENSHOTRECT] rectValue];  //打包成一个NSValue,用rectValue直接提取值就行
    
    CGImageRef image =CGDisplayCreateImageForRect(displays[0], rect);   //makeKeyAndOrderFront，再display 列表中0为前
    shareWindows=[[ShareWindowController alloc] initWithWindowNibName:@"ShareWindowController"];
    [shareWindows setImage:image];
    [shareWindows showWindow:nil]; 
    [shareWindows.window center];
    
    if (image)
    {
        CFRelease(image);
    }
    
    [_window setIsVisible:YES];
}

//接受上传请求
-(void) uploadScreenShot:(ASIFormDataRequest *)request{
    if (!_accessToken) {
        tmp_request=[request retain];
        [self userLogin:self.LoginBtn];
    } else{
        [request setPostValue:_accessToken forKey:USER_STORE_ACCESS_TOKEN];
        [self.networkQueue addOperation:request];
        
        [tmp_request release];
        tmp_request=nil;
    }
}


#pragma mark --------NETWORKQUEUE---------
-(void) requestStartedByQueue:(ASIHTTPRequest *)request{
    if(request.tag==3){
        self.window.title=@"上传中..";
    }
}

-(void) requestFinishedByQueue:(ASIHTTPRequest *)request{
    if (request.tag==1) {   //标签1，处理返回的token
        NSDictionary *tokenDictionary = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableLeaves error:nil];
        self.accessToken = [tokenDictionary objectForKey:@"access_token"];
        self.userID = [tokenDictionary objectForKey:@"uid"];
        NSString *remind_in = [tokenDictionary objectForKey:@"remind_in"];
        if (remind_in != nil)
        {
            int expVal = [remind_in intValue];
            self.expirationDate =  expVal == 0 ? [NSDate distantFuture]:[NSDate dateWithTimeIntervalSinceNow:expVal];
        }
        [[NSUserDefaults standardUserDefaults] setObject:self.accessToken forKey:USER_STORE_ACCESS_TOKEN];
        [[NSUserDefaults standardUserDefaults] setObject:self.userID forKey:USER_STORE_USER_ID];
        [[NSUserDefaults standardUserDefaults] setObject:self.expirationDate forKey:USER_STORE_EXPIRATION_DATE];
        NSLog(@"didReceiveData:%@",self.expirationDate);
        [self getUserInfoByToken];
        //如果有未完成的请求，则发起请求
        if (tmp_request) {
            [self uploadScreenShot:tmp_request];
        }
    }
    else if (request.tag==2){   //标签2,处理用户信息
        NSDictionary *userInfoDictionary = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"用户信息：%@",userInfoDictionary);
        NSInteger error_code = [[userInfoDictionary objectForKey:@"error_code"] intValue];
        if (error_code != 0)
        {
            [self userLogin:self.LoginBtn]; //如果token过期，则清空数据
            return;
        }
        
        self.weiboLink.title=[userInfoDictionary objectForKey:@"screen_name"];
        weiboURL=[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",@"http://weibo.com/",[userInfoDictionary objectForKey:@"profile_url"]]];
        self.LoginBtn.title=@"注销";
    }
    else if(request.tag==3){
        self.window.title=@"成功分享一张截图..";
//        NSString *str=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
//        NSLog(@"上传情况:%@",str);
    }
}
-(void) requestFailedByQueue:(ASIHTTPRequest *) request{
//    NSString *str=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",str);
}

-(void) queueFinished:(ASIHTTPRequest *) request{

}


/*
- (void)handleResponseData:(NSData *)data
{
    if ([delegate respondsToSelector:@selector(request:didReceiveRawData:)])
    {
        [delegate request:self didReceiveRawData:data];
    }
	id result = [self parseJSONData:data error:nil];

        NSInteger error_code = 0;
        [[result objectForKey:@"error_code"] intValue];

        if (error_code != 0)
        {
            NSString *error_description = [result objectForKey:@"error"];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      result, @"error",
                                      error_description, NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:kSinaWeiboSDKErrorDomain
                                                 code:[[result objectForKey:@"error_code"] intValue]
                                             userInfo:userInfo];
            
            if (error_code == 21314     //Token已经被使用
                || error_code == 21315  //Token已经过期
                || error_code == 21316  //Token不合法
                || error_code == 21317  //Token不合法
                || error_code == 21327  //token过期
                || error_code == 21332) //access_token 无效
            {
                [sinaweibo requestDidFailWithInvalidToken:error];
            }
            else
            {
                [self failedWithError:error];
            }
        }
        else
        {
            //正常接受
        }

}*/

@end
