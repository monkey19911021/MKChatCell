//
//  ViewController.m
//  MKChatCell
//
//  Created by M0nk1y-DONLINKS on 2017/6/15.
//  Copyright © 2017年 Donlinks. All rights reserved.
//

#import "ViewController.h"
#import "FlexBoxLayout.h"
#import "ChatingMsg.h"
#import "MKChatCellContentView.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, MKChatingCellDelegate>

@end

@implementation ViewController
{
    UITableView *chatTableView;
    NSMutableArray<ChatingMsg *> *chatMsgArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configureDataSource];
    
    [self configureTableView];
}

//设置数据源
-(void)configureDataSource {
    chatMsgArray = @[].mutableCopy;
    
    ChatingMsg *msg1 = [ChatingMsg new];
    msg1.fromUserName = @"皇叔刘备";
    msg1.toUserName = @"曹操";
    msg1.msgDirectionType = MSGDirectionTypeReceive;
    msg1.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg1.content = @"Hi~";
    [chatMsgArray addObject: msg1];
    
    ChatingMsg *msg2 = [ChatingMsg new];
    msg2.fromUserName = @"皇叔刘备";
    msg2.toUserName = @"曹操";
    msg2.msgDirectionType = MSGDirectionTypeReceive;
    msg2.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg2.content = @"曹操智计，殊绝于人，其用兵也，仿佛孙、吴，然困于南阳，险于乌巢，危于祁连，逼于黎阳，几败北山，殆死潼关，然后伪定一时耳；况臣才弱，而欲以不危而定之：此臣之未解三也";
    [chatMsgArray addObject: msg2];
    
    ChatingMsg *msg3 = [ChatingMsg new];
    msg3.fromUserName = @"皇叔刘备";
    msg3.toUserName = @"曹操";
    msg3.msgDirectionType = MSGDirectionTypeReceive;
    msg3.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg3.content = @"[图片]";
    msg3.attachFilePath = [[NSBundle mainBundle] pathForResource: @"101" ofType: @"png"];
    msg3.attachType = MSGAttachTypeImage;
    [chatMsgArray addObject: msg3];
    
    ChatingMsg *msg3_1 = [ChatingMsg new];
    msg3_1.fromUserName = @"皇叔刘备";
    msg3_1.toUserName = @"曹操";
    msg3_1.msgDirectionType = MSGDirectionTypeReceive;
    msg3_1.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg3_1.content = @"[录音]";
    msg3_1.attachFilePath = [[NSBundle mainBundle] pathForResource: @"testSong" ofType: @"mp3"];
    msg3_1.attachType = MSGAttachTypeAudio;
    [chatMsgArray addObject: msg3_1];
    
    ChatingMsg *msg4 = [ChatingMsg new];
    msg4.fromUserName = @"曹操";
    msg4.toUserName = @"皇叔刘备";
    msg4.msgDirectionType = MSGDirectionTypeSend;
    msg4.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg4.content = @"1";
    [chatMsgArray addObject: msg4];
    
    ChatingMsg *msg5 = [ChatingMsg new];
    msg5.fromUserName = @"曹操";
    msg5.toUserName = @"皇叔刘备";
    msg5.msgDirectionType = MSGDirectionTypeSend;
    msg5.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg5.content = @"对酒当歌，人生几何？"
    "譬如朝露，去日苦多。"
    "慨当以慷，忧思难忘。"
    "何以解忧，唯有杜康。"
    "青青子衿，悠悠我心。"
    "但为君故，沉吟至今。"
    "呦呦鹿鸣，食野之苹。"
    "我有嘉宾，鼓瑟吹笙。"
    "明明如月，何时可掇。"
    "忧从中来，不可断绝。"
    "越陌度阡，枉用相存。"
    "契阔谈宴，心念旧恩。"
    "月明星稀，乌鹊南飞。"
    "绕树三匝，何枝可依？"
    "山不厌高，海不厌深。"
    "周公吐哺，天下归心。";
    [chatMsgArray addObject: msg5];
    
    ChatingMsg *msg6 = [ChatingMsg new];
    msg6.fromUserName = @"曹操";
    msg6.toUserName = @"皇叔刘备";
    msg6.msgDirectionType = MSGDirectionTypeSend;
    msg6.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg6.content = @"[图片]";
    msg6.attachFilePath = [[NSBundle mainBundle] pathForResource: @"102" ofType: @"png"];
    msg6.attachType = MSGAttachTypeImage;
    [chatMsgArray addObject: msg6];
    
    ChatingMsg *msg6_1 = [ChatingMsg new];
    msg6_1.fromUserName = @"曹操";
    msg6_1.toUserName = @"皇叔刘备";
    msg6_1.msgDirectionType = MSGDirectionTypeSend;
    msg6_1.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg6_1.content = @"[录音]";
    msg6_1.attachFilePath = [[NSBundle mainBundle] pathForResource: @"testSong" ofType: @"mp3"];
    msg6_1.attachType = MSGAttachTypeAudio;
    [chatMsgArray addObject: msg6_1];
}

//设置tableView
-(void)configureTableView {
    chatTableView = [[UITableView alloc] initWithFrame:self.view.bounds style: UITableViewStylePlain];
    chatTableView.dataSource = self;
    chatTableView.delegate = self;
    chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    chatTableView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    [chatTableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"fb_kCellIdentifier"];
    [chatTableView fb_setCellContnetViewBlockForIndexPath:^UIView * _Nonnull(NSIndexPath * _Nonnull indexPath) {
        MKChatCellContentView *cellView = [[MKChatCellContentView alloc] initWithChatMsg: chatMsgArray[indexPath.row]
                                                                           withIndexPath: indexPath
                                                                                delegate: self];
        return cellView;
    }];
    chatTableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview: chatTableView];
}

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


#pragma mark - MKChatingCellDelegate
-(void)downLoadData:(NSIndexPath *)indexPath
    completeHandler:(void (^)(BOOL))completeHandler{
    
}


-(UIImage *)headImageForIndexPath:(NSIndexPath *)indexPath {
    return [UIImage imageNamed: @"head"];
}

-(void)reviewMemberInfo:(NSIndexPath *)indexPath {
    
}

-(NSArray<NSString *> *)allImageAttachFileParths {
    NSMutableArray *filePaths =@[].mutableCopy;
    for(ChatingMsg *msg in chatMsgArray){
        if(msg.attachType == MSGAttachTypeImage){
            [filePaths addObject: msg.attachFilePath];
        }
    }
    return filePaths;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

