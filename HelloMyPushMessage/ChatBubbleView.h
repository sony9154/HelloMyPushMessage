//
//  ChatBubbleView.h
//  HelloMyPushMessage
//
//  Created by Peter Yo on 4月/7/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatItem.h"



@interface ChatBubbleView : UIView

// 準備一個建構式 把相關數值帶進去
- (instancetype) initWithChatItem:(ChatItem*)item
               startFromY:(CGFloat) startY;








@end


























