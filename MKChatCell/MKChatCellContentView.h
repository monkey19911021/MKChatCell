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
 */
-(void)downLoadData:(NSIndexPath *)indexPath;


/**
 点击头像查看人员信息

 @param indexPath indexPath
 */
-(void)reviewMemberInfo:(NSIndexPath *)indexPath;

/**
 该聊天记录里所有的图片附件所在的位置，用于浏览聊天记录里的所有图片
 
 @return 附件ID数组
 */
-(NSArray<NSString *> *)allImageAttachFileParths;

@end

@class ChatingMsg;
@interface MKChatCellContentView : UIView

-(instancetype)initWithChatMsg:(ChatingMsg *)msg;

@property(strong, nonatomic) NSIndexPath *indexPath;

@property(weak, nonatomic) id<MKChatingCellDelegate> delegate;

@end
