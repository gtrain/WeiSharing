//
//  AppDelegate.h
//  WeiShare
//
//  Created by yang on 13-1-22.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/Graphics/IOGraphicsLib.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "ShareWindowController.h"
#import "FloatPanel.h"
#import "PanelView.h"
#import "Global.h"
#import "OAuthWebView.h"
#import "ASINetworkQueue.h"

@class ShareWindowController;

@interface AppDelegate : NSObject{
    /* displays[] Quartz display ID's */
	CGDirectDisplayID *displays;
    NSWindow *screenShotWindow;
    ShareWindowController *shareWindows;
    
    ASIFormDataRequest * tmp_request;
    NSURL *weiboURL;
}
-(void) uploadScreenShot:(ASIFormDataRequest *)request;
@property (strong) ASINetworkQueue *networkQueue;

@property (strong) NSString *accessToken;
@property (strong) NSString *userID;
@property (strong) NSDate *expirationDate;

@property (assign) IBOutlet NSWindow *window;
- (IBAction)shotBtnPress:(NSButton *)sender;


@property (assign) IBOutlet NSButton *LoginBtn;
- (IBAction)userLogin:(NSButton *)sender;

@property (assign) IBOutlet NSButton *weiboLink;
- (IBAction)OpenLink:(id)sender;

-(void) interrogateHardware;

@end
