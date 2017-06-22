//
//  MKChatCellContentView.m
//  MKChatCell
//
//  Created by M0nk1y-DONLINKS on 2017/6/15.
//  Copyright © 2017年 Donlinks. All rights reserved.
//

#import "MKChatCellContentView.h"
#import "ChatingMsg.h"
#import "FlexBoxLayout.h"
#import "UIImageView+CornerRadius.h"
#import "MKImagesReViewController.h"
#import <AVFoundation/AVFoundation.h>


#define BASE_COLOR ([UIColor colorWithRed: 0/255.0 green: 124.0/255.0 blue: 197.0/255 alpha:1])
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define BgColor ([UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1])

//8：头像框与父视图距离，40: 头像框宽度， 2: 头像框与对话框距离， 20：内容框与箭头距离,  12: 内容框与没有箭头那边的距离
#define ContentFrontMargin (20.0)
#define ContentBehindMargin (12.0)
#define ContentWidth (SCREEN_WIDTH - 8.0*2 - 40.0*2 - 2.0*2 - ContentFrontMargin - ContentBehindMargin)

@interface MKChatCellContentView () <AVAudioPlayerDelegate>

@end

@implementation MKChatCellContentView
{
    ChatingMsg *chatMsg;
    
    UIImageView *headImageView;
    
    UILabel *nameLabel;
    UILabel *msgTimeLable;
    UIImageView *backgroundImageView;
    
    UITextView *contentTextView;
    
    UIImageView *contentImageView;
    
    UIButton *audioBtn;
    UILabel *audioTimeLabel;
    
    UIActivityIndicatorView *activityIndicatorView;
    
    NSMutableArray<UIImage *> *leftVoiceImages;
    NSMutableArray<UIImage *> *rightVoiceImages;
    __block AVAudioPlayer *audioPlayer;
    
    BOOL isSend;
    NSDateFormatter *dateFormatter;
    NSFileManager *fileMgr;
    
    UIImage *rightImg;
    UIImage *leftImg;
}

-(instancetype)initWithChatMsg:(ChatingMsg *)msg withIndexPath:(NSIndexPath *)indexPath delegate:(id<MKChatingCellDelegate>)delegate{
    if(self = [super initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, 0)]){
        chatMsg = msg;
        _indexPath = indexPath;
        _delegate = delegate;
        isSend = chatMsg.msgDirectionType == MSGDirectionTypeSend;
        [self configView];
        [self configData];
        [self layoutView];
    }
    
    return self;
}

-(void)configView {
    
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
    
    fileMgr = [NSFileManager defaultManager];
    
    rightImg = [[UIImage imageNamed: @"canvas_right"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    leftImg = [[UIImage imageNamed: @"canvas_left"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    
    leftVoiceImages = @[].mutableCopy;
    rightVoiceImages = @[].mutableCopy;
    for(int i=1; i<4; i++){
        [leftVoiceImages addObject:[UIImage imageNamed: [NSString stringWithFormat:@"leftVoice%@", @(i)]]];
        [rightVoiceImages addObject:[UIImage imageNamed: [NSString stringWithFormat:@"rightVoice%@", @(i)]]];
    }
    
    headImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"head"]];
    headImageView.contentMode = UIViewContentModeScaleToFill;
    headImageView.backgroundColor = BgColor;
    headImageView.userInteractionEnabled = YES;
    [headImageView zy_cornerRadiusRoundingRect];
    [headImageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reviewMemberInfo)]];//添加点击头像查看员工信息
    [self addSubview: headImageView];
    
    nameLabel = [UILabel new];
    nameLabel.backgroundColor = BgColor;
    nameLabel.textColor = [UIColor darkGrayColor];
    nameLabel.textAlignment = isSend? NSTextAlignmentRight: NSTextAlignmentLeft;
    nameLabel.font = [UIFont systemFontOfSize: 12];
    [self addSubview: nameLabel];
    
    msgTimeLable = [UILabel new];
    msgTimeLable.backgroundColor = BgColor;
    msgTimeLable.textColor = [UIColor darkGrayColor];
    msgTimeLable.font = [UIFont systemFontOfSize: 10];
    msgTimeLable.textAlignment = isSend? NSTextAlignmentRight: NSTextAlignmentLeft;
    msgTimeLable.hidden = YES;
    [self addSubview: msgTimeLable];
    
    backgroundImageView = [[UIImageView alloc] initWithImage: isSend? rightImg: leftImg];
    backgroundImageView.backgroundColor = BgColor;
    backgroundImageView.tintColor = isSend? BASE_COLOR: [UIColor whiteColor];
    backgroundImageView.userInteractionEnabled = YES;
    [self addSubview: backgroundImageView];
    
    contentTextView = [UITextView new];
    contentTextView.backgroundColor = isSend? BASE_COLOR: [UIColor whiteColor];
    contentTextView.tintColor = isSend? [UIColor whiteColor]: BASE_COLOR;
    contentTextView.textColor = isSend? [UIColor whiteColor]: [UIColor blackColor];
    contentTextView.editable = NO;
    contentTextView.scrollEnabled = NO;
    contentTextView.showsHorizontalScrollIndicator = NO;
    contentTextView.showsVerticalScrollIndicator = NO;
    contentTextView.textContainer.lineFragmentPadding = 0; //消除边距
    contentTextView.textContainerInset = UIEdgeInsetsZero;
    contentTextView.textAlignment = NSTextAlignmentLeft;
    contentTextView.font = [UIFont systemFontOfSize: 17];
    [backgroundImageView addSubview: contentTextView];
    
    contentImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"imagePlaceholder"]];
    contentImageView.backgroundColor = isSend? BASE_COLOR: [UIColor whiteColor];
    contentImageView.contentMode = UIViewContentModeScaleAspectFit;
    contentImageView.userInteractionEnabled = YES;
    [contentImageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reviewImage)]];//添加浏览图片手势
    [backgroundImageView addSubview: contentImageView];
    
    audioBtn = [UIButton new];
    audioBtn.backgroundColor = isSend? BASE_COLOR: [UIColor whiteColor];
    audioBtn.contentHorizontalAlignment = isSend? UIControlContentHorizontalAlignmentRight: UIControlContentHorizontalAlignmentLeft;
    [audioBtn setImage:[UIImage imageNamed: isSend? @"rightVoice3": @"leftVoice3"] forState: UIControlStateNormal];
    audioBtn.imageView.animationImages = isSend? rightVoiceImages: leftVoiceImages;
    audioBtn.imageView.animationRepeatCount = 0;
    audioBtn.imageView.animationDuration = 1;
    [audioBtn addTarget: self action: @selector(playAudio) forControlEvents: UIControlEventTouchUpInside];
    [backgroundImageView addSubview: audioBtn];
    
    audioTimeLabel = [UILabel new];
    audioTimeLabel.font = [UIFont systemFontOfSize: 14];
    audioTimeLabel.textColor = [UIColor darkGrayColor];
    audioTimeLabel.backgroundColor = BgColor;
    audioTimeLabel.textAlignment = isSend? NSTextAlignmentRight: NSTextAlignmentLeft;
    [self addSubview: audioTimeLabel];
    
    activityIndicatorView = [UIActivityIndicatorView new];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicatorView.hidesWhenStopped = YES;
    activityIndicatorView.backgroundColor = [UIColor clearColor];
}

-(void)configData {
    //设置头像，一般头像都要去下载或者加载本地缓存
    if([_delegate respondsToSelector: @selector(headImageForIndexPath:)]){
        UIImage *headImg = [_delegate headImageForIndexPath: _indexPath];
        if(headImg){
            headImageView.image = headImg;
        }
    }
    
    //名字
    nameLabel.text = chatMsg.fromUserName;
    
    //消息时间
    msgTimeLable.text = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: chatMsg.sendDate/1000.0]];
    
    switch (chatMsg.attachType) {
        case MSGAttachTypeString:
            [self configTextView];
            break;
        case MSGAttachTypeImage:
            [self configImageView];
            break;
        case MSGAttachTypeAudio:
            [self configtAudioView];
            break;
        case MSGAttachTypeVideo:
            
            break;
        case MSGAttachTypeURL:
            
            break;
            
        default:
            break;
    }
}

-(void)configTextView {
    contentTextView.hidden = NO;
    contentImageView.hidden = YES;
    audioBtn.hidden = YES;
    
    contentTextView.text = chatMsg.content;
}

-(void)configImageView {
    contentTextView.hidden = YES;
    contentImageView.hidden = NO;
    audioBtn.hidden = YES;
    [contentImageView addSubview: activityIndicatorView];
    
    UIImage *image = [UIImage imageWithContentsOfFile: chatMsg.attachFilePath];
    if(image){
        contentImageView.image = image;
    }else{
        //图片缓存不存在，重新下载
        [self downloadData];
    }
}

-(void)configtAudioView {
    contentTextView.hidden = YES;
    contentImageView.hidden = YES;
    audioBtn.hidden = NO;
    
    NSData *audioData = [NSData dataWithContentsOfFile: chatMsg.attachFilePath];
    NSTimeInterval duration = 10;
    audioTimeLabel.text = @"";
    if(audioData){
        audioPlayer = [[AVAudioPlayer alloc] initWithData: audioData error: nil];
        audioPlayer.delegate = self;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioPlayer prepareToPlay];
        duration = audioPlayer.duration;
        NSInteger min = ((NSInteger)duration)/60;
        NSInteger sec = ((NSInteger)duration)%60;
        audioTimeLabel.text = min > 0? [NSString stringWithFormat:@"%@'%@''", @(min), @(sec)]: [NSString stringWithFormat:@"%@''", @(sec)];
    }else{
        //声音缓存不存在，重新下载
        [self downloadData];
    }
}

#pragma mark - 设置发送/接收方的聊天框
-(void)layoutView {
    //------------------
    [headImageView fb_makeLayout:^(FBLayout *layout) {
        layout.size.equalToSize(CGSizeMake(40, 40)).margin.equalToEdgeInsets(UIEdgeInsetsMake(0, isSend? 2: 8, 0, isSend? 8: 2)).wrapContent();
    }];
    
    //------------------
    [nameLabel fb_makeLayout:^(FBLayout *layout) {
        layout.wrapContent().margin.equalToEdgeInsets(UIEdgeInsetsMake(0, 8, 0, 8)).alignItems.equalTo(@(FBAlignFlexStart));
    }];
    [msgTimeLable fb_makeLayout:^(FBLayout *layout) {
        layout.wrapContent();
    }];
    FBLayoutDiv *titleDiv = [FBLayoutDiv layoutDivWithFlexDirection: isSend? FBFlexDirectionRowReverse: FBFlexDirectionRow
                                                     justifyContent: FBJustifyFlexStart
                                                         alignItems: FBAlignCenter
                                                           children:(@[nameLabel, msgTimeLable])];
    //------------------
    [activityIndicatorView fb_makeLayout:^(FBLayout *layout) {
        layout.wrapContent();
    }];
    
    [contentImageView fb_makeLayout:^(FBLayout *layout) {
        layout.flexDirection.equalTo(@(FBFlexDirectionRow))
        .justifyContent.equalTo(@(FBJustifyCenter))
        .alignItems.equalTo(@(FBAlignCenter))
        .margin.equalToEdgeInsets(UIEdgeInsetsMake(0, 0, 0, 0))
        .children(@[activityIndicatorView]);
    }];
    
    //------------------
    UIView *showView = contentTextView;
    UIEdgeInsets insets = UIEdgeInsetsMake(8, isSend? ContentBehindMargin: ContentFrontMargin, 8, isSend? ContentFrontMargin: ContentBehindMargin);
    switch (chatMsg.attachType) {
        case MSGAttachTypeString:
        {
            [contentTextView fb_makeLayout:^(FBLayout *layout) {
                layout.wrapContent()
                .margin.equalToEdgeInsets(insets)
                .maxWidth.equalTo(@(ContentWidth));
            }];
        }
            break;
        case MSGAttachTypeImage:
        {
            showView = contentImageView;
            [contentImageView fb_makeLayout:^(FBLayout *layout) {
                UIImage *image = contentImageView.image;
                CGSize imageSize = image.size;
                CGFloat width = image.size.width / [UIScreen mainScreen].scale;
                CGFloat height = image.size.height / [UIScreen mainScreen].scale;
                if(imageSize.width > 100.0){
                    imageSize = CGSizeMake(100.0, 100.0*imageSize.height/imageSize.width);
                    width = imageSize.width;
                    height = imageSize.height;
                }
                
                layout.margin.equalToEdgeInsets(insets)
                .width.equalTo(@(width))
                .height.equalTo(@(height));
            }];
        }
            break;
        case MSGAttachTypeAudio:
        {
            showView = audioBtn;
            [audioBtn fb_makeLayout:^(FBLayout *layout) {
                CGFloat width = audioPlayer.duration/13.0 * ContentWidth;
                if(width < 40.0){
                    width = 40.0;
                }
                
                if(width > ContentWidth){
                    width = ContentWidth;
                }
                layout.margin.equalToEdgeInsets(UIEdgeInsetsMake(4, insets.left, 4, insets.right))
                .width.equalTo(@(width))
                .height.equalTo(@(32));
            }];
        }
            break;
        case MSGAttachTypeVideo:
            
            break;
        case MSGAttachTypeTextFile:
            
            break;
        case MSGAttachTypeURL:
            
            break;
            
        default:
            break;
    }
    
    [backgroundImageView fb_makeLayout:^(FBLayout *layout) {
        layout.flexDirection.equalTo(@(isSend? FBFlexDirectionRowReverse: FBFlexDirectionRow))
        .justifyContent.equalTo(@(FBJustifyFlexStart))
        .alignItems.equalTo(@(FBAlignFlexStart))
        .margin.equalToEdgeInsets(UIEdgeInsetsMake(2, 0, 8, 0))
        .children(@[showView]);
        
        layout.wrapContent();
    }];
    
    [audioTimeLabel fb_makeLayout:^(FBLayout *layout) {
        layout.wrapContent()
        .margin.equalToEdgeInsets(UIEdgeInsetsMake(0, 6, 10, 6))
        .alignSelf.equalTo(@(FBAlignFlexEnd));
    }];
    
    FBLayoutDiv *contentDiv = [FBLayoutDiv layoutDivWithFlexDirection: isSend? FBFlexDirectionRowReverse: FBFlexDirectionRow
                                                       justifyContent: FBJustifyFlexStart
                                                           alignItems: FBAlignFlexStart
                                                             children: @[backgroundImageView, audioTimeLabel]];
    
    FBLayoutDiv *bodyDiv = [FBLayoutDiv layoutDivWithFlexDirection:FBFlexDirectionColumn
                                                    justifyContent:FBJustifyCenter
                                                        alignItems: isSend? FBAlignFlexEnd: FBAlignFlexStart
                                                          children:(@[titleDiv, contentDiv])];
    
    
    [self fb_makeLayout:^(FBLayout *layout) {
        layout.flexDirection.equalTo(isSend? @(FBFlexDirectionRowReverse): @(FBFlexDirectionRow))
        .justifyContent.equalTo(@(FBJustifyFlexStart))
        .alignItems.equalTo(@(FBAlignFlexStart))
        .margin.equalToEdgeInsets(UIEdgeInsetsMake(8, 0, 8, 0))
        .children(@[headImageView, bodyDiv]);
    }];
}


#pragma mark - 查看对话人资料
-(void)reviewMemberInfo {
    if([_delegate respondsToSelector: @selector(reviewMemberInfo:)]){
        [_delegate reviewMemberInfo: _indexPath];
    }
}

#pragma mark - 看图
- (void)reviewImage {
    if(![_delegate respondsToSelector: @selector(allImageAttachFileParths)]){
        return;
    }
    NSInteger index = -1;
    NSArray *filePaths = [_delegate allImageAttachFileParths];
    NSMutableArray *viableFilePaths = @[].mutableCopy; //存在缓存里的图片
    for(NSString *path in filePaths){
        if([fileMgr fileExistsAtPath: path]){ //过滤掉没缓存的照片
            [viableFilePaths addObject: path];
            
            NSString *fileName = [[path lastPathComponent] stringByDeletingPathExtension];
            if([fileName isEqualToString: chatMsg.attachID]){
                index = [filePaths indexOfObject: path];
            }
        }
    }
    
    if(index != -1){
        [[MKImagesReViewController new] showImages: viableFilePaths index: index afterDismissBlock:nil];
    }else{
        //图片缓存不存在，重新下载
        [self downloadData];
    }
    
}

#pragma mark - 播放音频
- (void)playAudio {
    if(audioPlayer){
        if(audioPlayer.isPlaying){
            [audioPlayer stop];
            [audioBtn.imageView stopAnimating];
        }else{
            [audioPlayer play];
            [audioBtn.imageView startAnimating];
        }
    }else{
        //音频缓存不存在，重新下载
        [self downloadData];
    }
}

#pragma mark - 下载数据
-(void)downloadData {
    if([_delegate respondsToSelector: @selector(downLoadData:completeHandler:)]){
        [activityIndicatorView startAnimating];
        [_delegate downLoadData: _indexPath completeHandler:^(BOOL success) {
            [activityIndicatorView stopAnimating];
        }];
    }
}

-(void)showMsgTime {
    if(msgTimeLable.hidden){
        msgTimeLable.alpha = 0;
        msgTimeLable.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            msgTimeLable.alpha = 1;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            msgTimeLable.alpha = 0;
        } completion:^(BOOL finished) {
            msgTimeLable.hidden = YES;
            msgTimeLable.alpha = 1;
        }];
    }
}

#pragma mark - AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [audioBtn.imageView stopAnimating];
}

@end
