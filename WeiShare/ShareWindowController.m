//
//  ShareWindowController.m
//  WeiShare
//
//  Created by yang on 13-1-22.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#import "ShareWindowController.h"

@interface ShareWindowController ()

@end

@implementation ShareWindowController
@synthesize wordNumber;
@synthesize textContent;
@synthesize ImageView=_imageView;

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.wordNumber.stringValue=[NSString stringWithFormat:@"%d",MAXWORDLENGHT];    //Max字数显示
    self.textContent.delegate=self;

}

#pragma mark -------截图的接收跟显示-------
//接受传过来的图片
- (void) setImage:(CGImageRef)ImageShot
{
    if (_image)
    {
        CFRelease(_image);
    }
    _image = (CGImageRef)CFRetain(ImageShot);  //保存原始截图
}
- (CGImageRef) getImage
{
    return _image;
}

#pragma mark -------处理信息，创建post请求-------
- (IBAction)ShareBtn:(NSButton *)sender {
    NSURL *url = [NSURL URLWithString:URL_POSTSTATUSESWITHIMG];
    NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_STORE_ACCESS_TOKEN];
    NSString *content = [self.textContent.stringValue isEqualToString:@""] ? @"分享图片" :self.textContent.stringValue;    //文字内容不能为空
    NSBitmapImageRep *imageRep=[[NSBitmapImageRep alloc] initWithCGImage:_image];
    NSData *imageData= [imageRep representationUsingType:NSPNGFileType properties:nil];
    
    ASIFormDataRequest *requestItem = [[ASIFormDataRequest alloc] initWithURL:url];
//    [requestItem setPostValue:authToken  forKey:USER_STORE_ACCESS_TOKEN];     //这里先不设置token，返回appdelegate再包装
    [requestItem setPostValue:content    forKey:USER_STORE_STATUS];
    [requestItem addData:imageData       forKey:USER_STORE_PIC];
    [self setPostUserInfo:requestItem withRequestType:SinaPostTextAndImage];

    requestItem.tag=3;
    AppDelegate *appdelegate=(AppDelegate *) [[NSApplication sharedApplication] delegate];
    [appdelegate uploadScreenShot:requestItem];
    
    [imageRep release];
    [requestItem release];
    [self close];
}

- (void)setPostUserInfo:(ASIFormDataRequest *)request withRequestType:(RequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:USER_INFO_KEY_TYPE];
    [request setUserInfo:dict];
    [dict release];
}

#pragma mark ----TextfieldDelegate----
//限制字数，显示剩余
-(void) controlTextDidChange:(NSNotification *)obj{
    NSTextField *textObj=[obj object];
    NSString *textString=textObj.stringValue;
    if (textString.length>MAXWORDLENGHT) {
        textObj.stringValue=[textString substringWithRange:NSMakeRange(0, MAXWORDLENGHT)];
    }
    int newWordNum=MAXWORDLENGHT-(int)textObj.stringValue.length;
    self.wordNumber.stringValue=[NSString stringWithFormat:@"%d",newWordNum]; 
}


@end







