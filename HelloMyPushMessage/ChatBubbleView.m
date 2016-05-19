//
//  ChatBubbleView.m
//  HelloMyPushMessage
//
//  Created by Peter Yo on 4月/7/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import "ChatBubbleView.h"

#define SIDE_PADDING_RATE       0.02 // 泡泡與螢幕邊緣的距離是整個螢幕寬的2%
#define MAX_BUBBLE_WIDTH_RATE   0.7  //泡泡的寬度是整個螢幕最大的多少比例70%
#define CONTENT_MARGIN          10.0 // 泡泡裡面的內容與泡泡的邊緣距離10px
#define BUBBLE_TAIL_WIDTH       10.0 // 泡泡尾巴的寬度10px
#define TEXT_SIZE               16.0 // 文字的大小

@interface ChatBubbleView()
{
    UIImageView *chatImageView;
    UILabel *chatLabel;
    UIImageView *backgroundImageView;
}

@end


@implementation ChatBubbleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) initWithChatItem:(ChatItem*)item
                       startFromY:(CGFloat) startY {
    CGRect selfFrame = [ChatBubbleView caculateBasicFrameWithType:item.type startFromY: startY];
    
    self = [super initWithFrame: selfFrame];
    
    CGFloat currentY = 0.0;
    
    // Prepare to display image
    UIImage *image = item.image;
    if(image != nil) {
        
        CGFloat x = CONTENT_MARGIN;
        CGFloat y = currentY + CONTENT_MARGIN;
        
        CGFloat displayWidth = MIN(image.size.width,selfFrame.size.width - 2 * CONTENT_MARGIN - BUBBLE_TAIL_WIDTH);
        // displayWidth：imageView顯示的寬 ;MIN 比較誰小就用誰
        
        CGFloat displayRatio = displayWidth / image.size.width; // 顯示的寬除上圖片的寬 然後得出比例
        CGFloat displayHeight = image.size.height * displayRatio; // 顯示的高就是維持原本的比例
        
        if(item.type == ChatItemtypeFromOthers) { //自己發的泡泡尾巴不影響x的值
            x += BUBBLE_TAIL_WIDTH;
        }
        
        CGRect displayFrame = CGRectMake(x, y, displayWidth, displayHeight);
        
        // Create chatImageView
        chatImageView = [[UIImageView alloc] initWithFrame:displayFrame];
        chatImageView.image = image;
        chatImageView.layer.cornerRadius = 5.0;
        chatImageView.layer.masksToBounds = true;
        [self addSubview:chatImageView];
        
        currentY += displayHeight + y; // 有圖片下要放文字的起始點
        
    }
    
    // Prepare to display text
    NSString *text = item.text;
    if(text != nil) {
        CGFloat x = CONTENT_MARGIN;
        CGFloat y = currentY + TEXT_SIZE/2; // TEXT_SIZE/2非必要
        if(item.type == ChatItemtypeFromOthers) {
            x += BUBBLE_TAIL_WIDTH;
        }
        CGRect labelFrame = CGRectMake(x, y, self.frame.size.width - 2*CONTENT_MARGIN - BUBBLE_TAIL_WIDTH, TEXT_SIZE);
        
        // Create Label
        chatLabel = [[UILabel alloc] initWithFrame:labelFrame];
        
        chatLabel.font = [UIFont systemFontOfSize:TEXT_SIZE];
        chatLabel.numberOfLines = 0; // Important !! UILabel本身可以指定用幾行顯示
        chatLabel.text = text;
        [chatLabel sizeToFit]; // 依照文字內容的多寡 去做最適切的內容調整
        
        [self addSubview:chatLabel];
        currentY += chatLabel.frame.size.height + CONTENT_MARGIN; //
    }
    
    // Caculate new size of bubble view
    CGFloat finalHeight = currentY + CONTENT_MARGIN;
    CGFloat finalWidth = 0.0;
    
    if(chatImageView != nil) {
        if(item.type == ChatItemTypeFromMe) {
            finalWidth = CGRectGetMaxX(chatImageView.frame) + CONTENT_MARGIN + BUBBLE_TAIL_WIDTH;
        }
        else //From Others
        {
            finalWidth = CGRectGetMaxX(chatImageView.frame) + CONTENT_MARGIN;
        }
    }
    if(chatLabel != nil) {
        CGFloat labelWidth;
        if(item.type == ChatItemTypeFromMe) {
            labelWidth = CGRectGetMaxX(chatLabel.frame) + CONTENT_MARGIN + BUBBLE_TAIL_WIDTH;
        }
        else
        {
            labelWidth = CGRectGetMaxX(chatLabel.frame) + CONTENT_MARGIN;
        }
        finalWidth = MAX(labelWidth, finalWidth);
    }
    // FromMe and text only.
    if(item.type == ChatItemTypeFromMe && chatImageView == nil) {
        selfFrame.origin.x += selfFrame.size.width - finalWidth;
    }
    selfFrame.size.width = finalWidth;
    selfFrame.size.height = finalHeight;
    self.frame = selfFrame;
    
    // Prepare background
    [self prepareBackgroundImageView:item.type];
    
    return self;
            
}


- (void) prepareBackgroundImageView:(ChatItemType) type {
    
    CGRect bgFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    backgroundImageView = [[UIImageView alloc] initWithFrame:bgFrame];
    
    if(type == ChatItemTypeFromMe) {
        
        UIImage *image = [UIImage imageNamed:@"fromMe.png"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 17, 28)];//對上14px,左下右
        backgroundImageView.image = image;
    }
    else // FromOthers
    {
        UIImage *image = [UIImage imageNamed:@"fromOthers.png"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(14, 22, 17, 20)];
        backgroundImageView.image = image;
    }
    
    [self addSubview:backgroundImageView];
    [self sendSubviewToBack:backgroundImageView];
    
}


+ (CGRect) caculateBasicFrameWithType:(ChatItemType) type
                           startFromY:(CGFloat)startY {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width; //邊界bounds蠻多時候和frame是一樣的
    CGFloat sidePadding = screenWidth * SIDE_PADDING_RATE;
    CGFloat maxWidth = screenWidth * MAX_BUBBLE_WIDTH_RATE;
    
    CGFloat startX; //泡泡x的值 ;會分兩種情況 自己和他人
    
    if(type == ChatItemTypeFromMe) {
     
        startX = screenWidth - sidePadding - maxWidth; //
    
    } else {
        //From Others
        
        startX = sidePadding;
    }
    
    return CGRectMake(startX,startY, maxWidth, 10.0);
    
}







@end


























