//
//  MKChatCellContentView.h
//  MKChatCell
//
//  Created by M0nk1y-DONLINKS on 2017/6/15.
//  Copyright © 2017年 Donlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MKChatingCellDelegate <NSObject>

/**
 下载数据
 
 @param indexPath indexPath
 @param completeHandler 下载完成处理块
 */
-(void)downLoadData: (NSIndexPath *)indexPath
    completeHandler: (void(^)(BOOL success))completeHandler;



/**
 获取聊天框的头像
 
 @param indexPath indexPath
 @return 头像图片
 */
-(UIImage *)headImageForIndexPath:(NSIndexPath *)indexPath;

/**
 点击头像查看人员信息
 
 @param indexPath indexPath
 */
-(void)reviewMemberInfo: (NSIndexPath *)indexPath;

/**
 该聊天记录里所有的图片附件所在的位置，用于浏览聊天记录里的所有图片
 
 @return 附件ID数组
 */
-(NSArray<NSString *> *)allImageAttachFileParths;

@end

@class ChatingMsg;
@interface MKChatCellContentView : UIView

-(instancetype)initWithChatMsg: (ChatingMsg *) msg
                 withIndexPath: (NSIndexPath *) indexPath
                      delegate: (id<MKChatingCellDelegate>) delegate;

@property(strong, nonatomic) NSIndexPath *indexPath;

@property(weak, nonatomic) id<MKChatingCellDelegate> delegate;


-(void)showMsgTime;

@end
