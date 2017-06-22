//
//  ChatMsg.h
//  MKChatCell
//
//  Created by M0nk1y-DONLINKS on 2017/6/15.
//  Copyright © 2017年 Donlinks. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MSGDirectionType) {
    MSGDirectionTypeSend = 0,
    MSGDirectionTypeReceive
};

typedef NS_ENUM(NSInteger, MSGAttachType) {
    MSGAttachTypeString = 0,
    MSGAttachTypeImage = 1,
    MSGAttachTypeAudio = 2,
    MSGAttachTypeVideo = 3,
    MSGAttachTypeTextFile = 4,
    MSGAttachTypeURL = 5
};

@interface ChatingMsg : NSObject

@property(copy, nonatomic) NSString *fromUserName;//发送人名字
@property(copy, nonatomic) NSString *toUserName;//接收人名字, 群聊里是房间名
@property(assign, nonatomic) MSGDirectionType msgDirectionType; //是发送还是接受
@property(assign, nonatomic) NSTimeInterval sendDate;//": "发送时间，时间毫秒数",
@property(copy, nonatomic) NSString *content;//": "文字内容",
@property(copy, nonatomic) NSString *attachFilePath; //附件数据位置
@property(copy, nonatomic) NSString *attachID;//": "附件ID",
@property(assign, nonatomic) MSGAttachType attachType;//": "附件类型，0: 文字，1: 图片, 2: 音频, 3: 视频, 4: 文本文件（如word、ppt） 5: URL地址",

@end
