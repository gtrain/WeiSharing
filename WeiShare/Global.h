//
//  Global.h
//  OA_Test
//
//  Created by yang on 13-1-24.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#ifndef Global_h
#define Global_h

//软件开发信息
#define kAppKey             @"4037834572"
#define kAppSecret          @"8175a3232cdd33551a62e7fc509b79e9"
#define kAppRedirectURI     @"http://vdisk.weibo.com/u/1841185175"

//OAuth 认证信息
#define USER_STORE_CODE                 @"code"
#define USER_STORE_ACCESS_TOKEN         @"access_token"
#define USER_STORE_USER_ID              @"uid"
#define USER_STORE_EXPIRATION_DATE      @"expires_in"

#define USER_STORE_STATUS               @"status"
#define USER_STORE_PIC                  @"pic"

//通知中心:成功获取TOKEN信息
#define DID_GET_CODE                    @"didGetCodeInWebView"

//通知中心:截图完成，包含截图信息
#define SCREENSHOTRECT                  @"screenShotRect"
#define DID_GET_SNAPSHOT                @"didGetSnapShot"

#define USER_INFO_KEY_TYPE              @"requestType"

//微博字数限制
#define MAXWORDLENGHT   140


//微博API
#define URL_POSTSTATUSESWITHIMG         @"https://api.weibo.com/2/statuses/upload.json"
#define kSinaWeiboWebAccessTokenURL     @"https://open.weibo.cn/2/oauth2/access_token"
#define kSinaWeiboWebAuthURL            @"https://open.weibo.cn/2/oauth2/authorize" 
#define kSinaWeiboUserInfo              @"https://open.weibo.cn/2/users/show.json"

#endif