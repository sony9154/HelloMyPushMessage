//
//  ChattingView.h
//  HelloMyPushMessage
//
//  Created by Peter Yo on 4月/7/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatItem.h"

@interface ChattingView : UIScrollView

- (void) addChatItem:(ChatItem*) item;

- (void) relayoutAllChatItems;

@end
