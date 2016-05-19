//
//  ViewController.m
//  HelloMyPushMessage
//
//  Created by Peter Yo on 4月/1/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import "ViewController.h"
#import "Communicator.h"
#import "AppDelegate.h"
#import "ChattingView.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define USER_NAME @"Me"

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    Communicator *comm; //好幾個VC都會用到它
    NSInteger lastMessageID;
    
    NSMutableArray *incomingMessages;
    
    BOOL isRefreshing;
    BOOL shouldRefreshAgain;//這變數是用來記錄在refresh過程中時 是不是又有推播通知新內容
}
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet ChattingView *chattingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    comm = [Communicator sharedInstance];
    comm.userName = USER_NAME;
    [comm reportDeviceToken];
    
    //Prepare lastMessageID
    lastMessageID = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_MESSAGE_ID_KEY];//integerForKey 會吐那個key的value
    
    if(lastMessageID == 0) {
    lastMessageID = 1;//php裡面數字0會被判斷為空
    }
    
    lastMessageID = 5700; // Hardcode to download message > 5000.
    
    incomingMessages = [NSMutableArray new];
    
    NSLog(@"lastMessageID from NSUserDefaults: %ld", lastMessageID);
    
    // Support SHOULD_REFRESH_MESSAGES_NOTIFICATION
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBtnPressed:) name:SHOULD_REFRESH_MESSAGES_NOTIFICATION object:nil];
    
    // Refresh at view controller startup
    [self refreshBtnPressed:nil];
    
    // Change background color of chattingView
    [self.chattingView setBackgroundColor:[UIColor colorWithRed:37.0/255.0 green:174.0/255.0 blue:230.0/255.0 alpha:1.0]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.chattingView relayoutAllChatItems];
}


- (IBAction)sendBtnPressed:(id)sender {
    
    if(self.inputTextField.text.length == 0){
        return;
    }
    [self.inputTextField resignFirstResponder]; //Dismiss the Keyboard
    
    [comm sendMessage:self.inputTextField.text Completion:^(NSError *error, id result) {
        
        NSDictionary *resultDictionary = result;
        NSNumber *resultValue = resultDictionary[RESULT_KEY];
        Boolean success = [resultValue boolValue];
        
        if(error) {
            //Fail
            [self addToLog:error.description];
        }
        //else if([[result valueForKey:RESULT_KEY] boolValue] == false)
        else if (success == false)
        {
            NSString *errorCode = resultDictionary[ERRORCODE_KEY];
            [self addToLog:errorCode];
        }
        else {
            // Success
            [self refreshBtnPressed:nil];
        }
    }];
    
}

- (IBAction)photoBtnPressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose Image Source" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
    
    
}

- (IBAction)refreshBtnPressed:(id)sender {
    
    
    @synchronized (self)// 可以防止不同的thread進來
    {
        if(isRefreshing) { //正在refresh就跳掉不做
            shouldRefreshAgain = true;//refresh後還要再做一次refresh(有新東西進來 )
        return;
        }
        isRefreshing = true;
    }
    
    
    [comm downloadWithLastMessageID:lastMessageID completion:^
        (NSError *error, id result) {
            
        if(error) { //傳輸的error
            [self addToLog:error.description];
            @synchronized (self) {
                isRefreshing = false;//有異常就停掉,讓它恢復可以refresh的狀態
            }
        }
        else if([[result valueForKey:RESULT_KEY] boolValue] == false) {
            [self addToLog:[result valueForKey:ERRORCODE_KEY]];
            @synchronized (self) {
                isRefreshing = false;
            }
        }
        else {
            // Handle all messages
            NSArray *messages = [result valueForKey:MESSAGES_KEY];
            
            // Return if there is no new message
            if(messages.count == 0) {
                @synchronized (self) {
                    isRefreshing = false; //return前也要設成false
                }
                return;
            }
            
            // Put messages into incomingMessages, then handle it one by one.
            [incomingMessages addObjectsFromArray:messages];
            
            [self handleIncomingMessages];
            
            
            NSString *allLogText = @"";
            for(NSDictionary *tmpMsg in messages) {
                NSString *logText = [NSString stringWithFormat:@"[%ld] %@:%@",[tmpMsg
                    [ID_KEY] integerValue],tmpMsg[USER_NAME_KEY],tmpMsg[MESSAGE_KEY]];
                NSLog(@"%@" , logText);
                allLogText = [NSString stringWithFormat:@"%@\n%@",logText,allLogText];
                
            }
            [self addToLog:allLogText];
            
            // Keep lastMessageID
//            NSDictionary *lastMsg = messages.lastObject;
//            lastMessageID = [lastMsg[ID_KEY] integerValue];//下次refreash就會從最新的id吐回
            

        }
        
        
    }];
    
    
}

- (void) addToLog:(NSString*)logText {
    
    self.logTextView.text = [NSString stringWithFormat:@"%@\n%@",logText,self.logTextView.text];
    
}


- (void) handleIncomingMessages {
    if(incomingMessages.count == 0) {
        return;
    }
    
    NSDictionary *tmpMessage = incomingMessages.firstObject;
    [incomingMessages removeObjectAtIndex:0];
    
    NSInteger messageID = [tmpMessage[ID_KEY] integerValue];
    NSInteger messageType = [tmpMessage[MESSAGE_TYPE_KEY] integerValue];
    
    if(messageType == 0) // Text Message
    {
        NSString *displayMessage = [NSString stringWithFormat:@"%@: %@ (%ld)",tmpMessage[USER_NAME_KEY],tmpMessage[MESSAGE_KEY],(long)messageID];
        
        
        
        [self addToChattingViewWithMessage:displayMessage withPhoto:nil];
        
        // Move to next message
        [self checkAndHandleNextMessageWithLastMessageID:messageID];
        
    }
    else if(messageType == 1) // Photo Message 
    {
        
        [comm downloadWithFileName:tmpMessage[MESSAGE_KEY]
                        completion:
         ^(NSError *error, id result) {
           
             if(error) {
                 NSLog(@"Fail to download file: %@\nreason:%@",tmpMessage[MESSAGE_KEY],error.description);
                 return ;
             }
             // Download OK,show the photo
             UIImage *photo = [UIImage imageWithData:result];
             
             NSString *displayMessage = [NSString stringWithFormat:@"%@: %@ (%ld)",
                      tmpMessage[USER_NAME_KEY],tmpMessage[MESSAGE_KEY],(long) messageID];
             [self addToLog:displayMessage];
             
             [self addToChattingViewWithMessage:displayMessage withPhoto:photo];
             
             // Move to next message
             [self checkAndHandleNextMessageWithLastMessageID:messageID];
             
         }];
        
    }
    
    
}

- (void) checkAndHandleNextMessageWithLastMessageID:(NSInteger)messageID {
    if(incomingMessages.count == 0) {
        // Stop and Save
        lastMessageID = messageID;
        
        // Save to NSUserDefault 存放少量資料
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:lastMessageID forKey:LAST_MESSAGE_ID_KEY];
        [defaults synchronize]; // 寫入資料要存起來一定要 synchronize！！！
        
        //結束的地方
        @synchronized (self) {
            isRefreshing = false;
        }
        // Make another refresh after current refresh.
        if(shouldRefreshAgain) {
            shouldRefreshAgain = false;
            [self refreshBtnPressed:nil];
        }
        
    } else {
        [self handleIncomingMessages];
    }
}

- (void) addToChattingViewWithMessage:(NSString*)message withPhoto:(UIImage*)image {
    
    ChatItem *item = [ChatItem new];
    
    if([message hasPrefix:USER_NAME]) {
        item.type = ChatItemTypeFromMe;
    } else  {
        item.type = ChatItemtypeFromOthers;
    }
    
    item.text = message;
    item.image = image;
    
    [self.chattingView addChatItem:item];
    
}

- (IBAction)chattingViewTapped:(id)sender {
    
    [self.inputTextField resignFirstResponder];
    
}

#pragma mark - UIImagePickerController Support

- (void) launchImagePickerWithSourceType:(UIImagePickerControllerSourceType) sourceType {
    
    if([UIImagePickerController isSourceTypeAvailable:sourceType] == false) {
        NSLog(@"SourceType is not supported.");
        return;
    }
    // Prepare UIImagePickerController
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = sourceType;
    //imagePicker.mediaTypes = @[@"public.image"];
    imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];//支援的媒體是哪一個種類 (拍照/ 錄影 ,照片/影片)
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:true completion:nil];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)
    info {
    
    NSString *type = info[UIImagePickerControllerMediaType];
    
    if([type isEqualToString:(NSString*)kUTTypeImage]) {
        //Image
        
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        
        UIImage *resizedImage = [self resizeFromImage:originalImage];
        
        NSData *jpegData = UIImageJPEGRepresentation(resizedImage, 0.6);
        NSLog(@"PhotoSize: %fx%f (%ld bytes)",originalImage.size.width,originalImage.size.height,(unsigned long)jpegData.length);
        [comm sendPhotoMessage:jpegData completion:^(NSError *error, id result) {
            if(error) {
                NSLog(@"Error in send photo message: %@",error.description);
            } else {
                [self refreshBtnPressed:nil];
            }
        }];
        
    } else {
        //Movie
        
    }
    [picker dismissViewControllerAnimated:true completion:nil];
    
}

- (UIImage*) resizeFromImage:(UIImage*) sourceImage {
    
    //Check sourceImage's size
    CGFloat maxValue = 1024.0;
    CGSize originalSize = sourceImage.size;
    if(originalSize.width <= maxValue && originalSize.height <= maxValue) {
        return sourceImage;
    }
    
    //Decide final size
    CGSize targetSize;
    if(originalSize.width >= originalSize.height) { //如果原圖寬大於高
        CGFloat ratio = originalSize.width/maxValue;//ratio倍率
        targetSize = CGSizeMake(maxValue, originalSize.height/ratio);//維持比列的情況下,最長邊會降到1024以下
    } else {
        // height > width
        CGFloat ratio = originalSize.height/maxValue;
        targetSize = CGSizeMake(originalSize.height/ratio, maxValue);
    }
    
    UIGraphicsBeginImageContext(targetSize); //要求系統建立一塊虛擬的畫布,size是50*50,虛擬的畫布不會在任何地方以UI的形式讓你看到,但會佔用一塊記憶體在那邊
    
    [sourceImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    //把進來的圖片sourceImage,drawInRect畫在虛擬畫布上,
    
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();//把目前虛擬畫布的內容輸出成UIImage
    
    UIGraphicsEndImageContext();// 非常重要！有Begin就要有End結束(C的函式).
    
    return resultImage;
}


@end


































