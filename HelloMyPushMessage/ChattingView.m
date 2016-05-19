//
//  ChattingView.m
//  HelloMyPushMessage
//
//  Created by Peter Yo on 4月/7/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import "ChattingView.h"
#import "ChatBubbleView.h"

#define BUBBLE_VIEW_Y_PADDING   20 //泡泡對話框的距離


@interface ChattingView()
{
    NSMutableArray *allChatItems;
    CGFloat lastChatBubbleViewY; // 記住泡泡view結束的位置
}

@end

@implementation ChattingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) addChatItem:(ChatItem *)item {
    
    // Keep all chat items
    if(allChatItems == nil) {
        allChatItems = [NSMutableArray new];
    }
    [allChatItems addObject:item];
    
    // Prepare ChatBubbleView and add to ChattingView
    ChatBubbleView *bubbleView = [[ChatBubbleView alloc]
                                  initWithChatItem:item startFromY:lastChatBubbleViewY + BUBBLE_VIEW_Y_PADDING];
    
    [self addSubview:bubbleView];
    
    lastChatBubbleViewY = CGRectGetMaxY(bubbleView.frame);
    self.contentSize = CGSizeMake(self.frame.size.width, lastChatBubbleViewY);
    //contentSize代表ScrollView的內容有多少(寬不變,高是最後一個bubbleview的y)
    
    // Scroll to bottom
    [self scrollRectToVisible:CGRectMake(0, lastChatBubbleViewY -1, 1, 1) animated:true];
    
    // To be continued ......
    
}

- (void) relayoutAllChatItems {
    
    // Remove all subviews
    for(id view in self.subviews) {
        [view removeFromSuperview];
    }
    
    lastChatBubbleViewY = 0;
    
    // Recreate all subviews
    NSMutableArray *originalItems = allChatItems;
    allChatItems = [NSMutableArray new];
    
    for(ChatItem *item in originalItems) {
        [self addChatItem:item];
    }
    
}




@end

























