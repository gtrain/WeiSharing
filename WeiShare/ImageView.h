//
//  ImageView.h
//  WeiShare
//
//  Created by yang on 13-1-22.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ShareWindowController.h"

@interface ImageView : NSView{
@private
    IBOutlet ShareWindowController *shareWindowController;
}

@end
