//
//  ChatItem.h
//  HelloMyPushMessage
//
//  Created by Peter Yo on 4月/7/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger { // enum是把同類型的常數定義在一起
    ChatItemTypeFromMe = 0,
    ChatItemtypeFromOthers = 1
} ChatItemType;

@interface ChatItem : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) ChatItemType type; // NSUInteger是純數字所以用assign,strong用於class

@end
