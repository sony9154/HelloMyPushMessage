//
//  Communicator.h
//  HelloMyPushMessage
//
//  Created by Peter Yo on 4月/1/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ID_KEY              @"id"
#define USER_NAME_KEY       @"UserName"
#define MESSAGE_KEY         @"Message"
#define DEVICETOKEN_KEY     @"DeviceToken"
#define GROUP_NAME_KEY      @"GroupName"
#define MESSAGES_KEY        @"Messages"
#define MESSAGE_TYPE_KEY    @"Type"
#define LAST_MESSAGE_ID_KEY @"LastMessageID"
#define DATA_KEY            @"data"
#define RESULT_KEY          @"result"
#define ERRORCODE_KEY       @"errorCode"

typedef void (^DoneBlock)(NSError *error,id result);

@interface Communicator : NSObject

@property (nonatomic,strong) NSString *deviceToken;
@property (nonatomic,strong) NSString *userName;

- (void) reportDeviceToken;
- (void) sendMessage:(NSString*)message Completion:(DoneBlock)doneBlock;

-(void) sendPhotoMessage:(NSData*)imageData completion:(DoneBlock)doneBlock;

- (void) downloadWithLastMessageID:(NSInteger)lastMessageID completion:(DoneBlock) doneBlock;

- (void) downloadWithFileName:(NSString*)filename completion:(DoneBlock)doneBlock;

+ (instancetype) sharedInstance;


@end















