//
//  Communicator.m
//  HelloMyPushMessage
//
//  Created by Peter Yo on 4月/1/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import "Communicator.h"
#import <AFNetworking.h>

#define BASE_URL @"http://class.softarts.cc/PushMessage"

#define SENDMESSAGE_URL [BASE_URL stringByAppendingPathComponent:@"sendMessage.php"]

#define SENDPHOTOMESSAGE_URL [BASE_URL stringByAppendingPathComponent:@"sendPhotoMessage.php"]

#define RETRIVEMESSAGES_URL [BASE_URL stringByAppendingPathComponent:@"retriveMessages2.php"]

#define UPDATEDEVICETOKEN_URL [BASE_URL stringByAppendingPathComponent:@"updateDeviceToken.php"]

#define PHOTOS_BASE_URL [BASE_URL stringByAppendingPathComponent:@"photos/"]

#define GROUP_NAME @"AP101"

@implementation Communicator

static Communicator *_singletonCommunicator = nil;

+ (instancetype) sharedInstance {
    
    if(_singletonCommunicator == nil) {
        _singletonCommunicator = [Communicator new];
    }
    return _singletonCommunicator;
}

#pragma mark - Public Methods

- (void) reportDeviceToken {
    
    if(_deviceToken == nil || _userName == nil) {
        return;
    }
    
    // Report to server
    NSDictionary *jsonObj = @{GROUP_NAME_KEY:GROUP_NAME,
                              USER_NAME_KEY:_userName,DEVICETOKEN_KEY:_deviceToken};
    [self doHttpPost:UPDATEDEVICETOKEN_URL //API吃的欄位會不同
          parameters:jsonObj
          completion:^(NSError *error, id result) {
    }];
    
}

- (void) sendMessage:(NSString*)message Completion:(DoneBlock)doneBlock {

    if(self.userName == nil || message == nil) {
        return;
    }
    
    // Send Message to Server
    NSDictionary *jsonObj = @{GROUP_NAME_KEY:GROUP_NAME,USER_NAME_KEY:self.userName,MESSAGE_KEY:message};
    
    /*
    [self doHttpPost:SENDMESSAGE_URL parameters:jsonObj completion:^(NSError *error, id result) {
        doneBlock(error,result);
    }];
     */
    //可以用下面的取代
    [self doHttpPost:SENDMESSAGE_URL parameters:jsonObj completion:doneBlock];
    
}

-(void) sendPhotoMessage:(NSData*)imageData completion:(DoneBlock)doneBlock {
    
    if(self.userName == nil || imageData == nil) {
        return;
    }
    
    NSDictionary *jsonObj = @{GROUP_NAME_KEY:GROUP_NAME,USER_NAME_KEY:self.userName};
    
    [self doHttpPost:SENDPHOTOMESSAGE_URL parameters:jsonObj data:imageData completion:doneBlock];
}


- (void) downloadWithLastMessageID:(NSInteger)lastMessageID completion:(DoneBlock) doneBlock {
    
    NSDictionary *jsonObj = @{GROUP_NAME_KEY:GROUP_NAME,LAST_MESSAGE_ID_KEY:@(lastMessageID)};// dictionary不能放純值類的東西 所以要@轉物件
    
    [self doHttpPost:RETRIVEMESSAGES_URL parameters:jsonObj completion:doneBlock];
    
}

- (void) downloadWithFileName:(NSString*)filename completion:(DoneBlock)doneBlock {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//把從server要到的東西傳回來
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"image/jpeg"];
    NSString *finalImageFilePath = [PHOTOS_BASE_URL stringByAppendingPathComponent:filename];
    
    [manager GET:finalImageFilePath
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             
             NSLog(@"Get OK: %ld bytes",[responseObject length]);
             doneBlock(nil,responseObject);
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Get Fail: %@", [error description]);
             doneBlock(error,nil);
         }];
    
    
}



#pragma mark - Private Methods

//HTTP POST才是安全的做法
- (void) doHttpPost:(NSString*)urlString
         parameters:(NSDictionary*)parameters
               data:(NSData*)data
         completion:(DoneBlock)doneBlock {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];//Dict去轉json;NSJSONWritingPrettyPrinted:轉json後印出來比較好看的形式
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *finalParameters = @{DATA_KEY:jsonString};//重新封裝成data= ...
    
    // Use AFNetworking
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];//基本型的 http post用法
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:urlString
       parameters:finalParameters //加工後的data=...
    constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) { //formData是afnetworking自己定義的
    
        [formData appendPartWithFileData:data name:@"fileToUpload" fileName:@"image.png" mimeType:@"image/jpg"];//fileToUpload這名字要和server端配合
        
            }
         progress:nil // 可看到連線進度
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) { //
              NSLog(@"Post OK: %@",[responseObject description]);
              doneBlock(nil,responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { //
              NSLog(@"Post Fail: %@",[error description]);
              doneBlock(error,nil);
          }];
    
}

//HTTP POST才是安全的做法
- (void) doHttpPost:(NSString*)urlString
         parameters:(NSDictionary*)parameters
         completion:(DoneBlock)doneBlock {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];//Dict去轉json;NSJSONWritingPrettyPrinted:轉json後印出來比較好看的形式
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *finalParameters = @{DATA_KEY:jsonString};//重新封裝成data= ...
    
    // Use AFNetworking
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];//基本型的 http post用法
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:urlString
       parameters:finalParameters //加工後的data=...
         progress:nil // 可看到連線進度
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) { //
              NSLog(@"Post OK: %@",[responseObject description]);
              doneBlock(nil,responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { //
              NSLog(@"Post Fail: %@",[error description]);
              doneBlock(error,nil);
          }];
    
}


@end




















