
[原文地址](http://mkapple.cn/2017/06/22/ChatCell)


![截图1](http://mkapple.cn/images/ChatCell/img.gif)

## 即时通讯聊天框
我们来做一个像QQ、微信那样的即时通讯应用的聊天框吧。所用的库有：

1. [FlexBoxLayout](https://github.com/LPD-iOS/FlexBoxLayout)，它是一个基于 Yoga 开源库进行开发的布局工具，用的是 Frame 布局，比约束布局性能高出很多，特别是支持自动高度、布局缓存，contentView 缓存，和自动 cache 失效机制。这里是中文教程：[www.ruanyifeng.com](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)
2. [CornerRadiusCategory](https://github.com/liuzhiyi1992/ZYCornerRadius)，解决圆角带来的离屏渲染导致帧数下降的问题。
3. [MKImagesReViewController](https://github.com/monkey19911021/MKImageReview)，我自己开发的图片浏览器，支持多图浏览，放大无缝，保存图片到手机，最重要的是支持查看 gif 格式的图片。


### 1. 封装消息 Model
```objc
@property(copy, nonatomic) NSString *fromUserName;  //发送人名字
@property(copy, nonatomic) NSString *toUserName;    //接收人名字, 群聊里是房间名
@property(assign, nonatomic) MSGDirectionType msgDirectionType; //是发送还是接受
@property(assign, nonatomic) NSTimeInterval sendDate;   //发送时间，时间毫秒数
@property(copy, nonatomic) NSString *content;   //文字内容
@property(copy, nonatomic) NSString *attachFilePath;    //附件数据位置
@property(assign, nonatomic) MSGAttachType attachType;  //附件类型，0: 文字，1: 图片, 2: 音频, 3: 视频, 4: 文本文件（如word、ppt） 5: URL地址
```

注意：因为考虑到服务器和安卓端的时间戳是毫秒为单位的，而iOS是秒为时间戳单位，所以我们的时间使用毫秒为单位。

### 2. 封装聊天框，UITableViwCell 的内容视图

#### 2.1. 协议方法
```objc
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
```

下载的协议方法用于当滑动到某个非文本内容的聊天框时，需要加载附件，但是本地没有缓存需要进行下载，则可以调用此方法进行下载。

#### 2.2. 内部成员变量
```objc
ChatingMsg *chatMsg;

//头像
UIImageView *headImageView;

//名字
UILabel *nameLabel;
//消息时间
UILabel *msgTimeLable;
//背景图，即对话泡
UIImageView *backgroundImageView;

//文本内容
UITextView *contentTextView;

//图片内容
UIImageView *contentImageView;

//音频内容
UIButton *audioBtn;
//音频时间
UILabel *audioTimeLabel;
NSMutableArray<UIImage *> *leftVoiceImages;
NSMutableArray<UIImage *> *rightVoiceImages;
AVAudioPlayer *audioPlayer;

//活动指示图
UIActivityIndicatorView *activityIndicatorView;

BOOL isSend; //聊天框是发送样式还是接受样式
NSDateFormatter *dateFormatter;

UIImage *rightImg;
UIImage *leftImg;
```

#### 2.3. 重点，100多行代码搞掂布局
```objc
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
```

看不懂以上代码没关系，先去看看[FlexBoxLayout中文教程](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)，其实并不难，理解好了就好用了。

#### 2.4. UITableView 使用 FlexBoxLayout
```objc
[chatTableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"fb_kCellIdentifier"]; //先去注册cell，identifier 一定要使用 fb_kCellIdentifier
[chatTableView fb_setCellContnetViewBlockForIndexPath:^UIView * _Nonnull(NSIndexPath * _Nonnull indexPath) {
    MKChatCellContentView *cellView = [[MKChatCellContentView alloc] initWithChatMsg: chatMsgArray[indexPath.row]
                                                                       withIndexPath: indexPath
                                                                            delegate: self];
    return cellView;
}];
    
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return chatMsgArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fb_heightForIndexPath: indexPath];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fb_cellForIndexPath: indexPath];
}
```

tableView 的高度都是自动计算的，自己就不用操心了。


Demo：[https://github.com/monkey19911021/MKChatCell](https://github.com/monkey19911021/MKChatCell)
<br>
