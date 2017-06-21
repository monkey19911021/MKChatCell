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
    msg2.content = @"曹操那厮快出来！曹操那厮快出来！曹操那厮快出来！曹操那厮快出来！曹操那厮快出来！曹操那厮快出来！曹操那厮快出来！曹操那厮快出来！曹操那厮快出来！";
    [chatMsgArray addObject: msg2];
    
    ChatingMsg *msg3 = [ChatingMsg new];
    msg3.fromUserName = @"皇叔刘备";
    msg3.toUserName = @"曹操";
    msg3.msgDirectionType = MSGDirectionTypeReceive;
    msg3.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg3.content = @"[图片]";
    msg3.attachID = @"101";
    msg3.attachData = UIImageJPEGRepresentation([UIImage imageNamed: msg3.attachID], 1);
    msg3.attachType = MSGAttachTypeImage;
    [chatMsgArray addObject: msg3];
    
    ChatingMsg *msg3_1 = [ChatingMsg new];
    msg3_1.fromUserName = @"皇叔刘备";
    msg3_1.toUserName = @"曹操";
    msg3_1.msgDirectionType = MSGDirectionTypeReceive;
    msg3_1.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg3_1.content = @"[录音]";
    msg3_1.attachData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"testSong" ofType: @"mp3"]];
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
    msg5.content = @"测试多行！测试多行！测试多行！测试多行！测试多行！测试多行！测试多行！测试多行！测试多行！测试多行！测试多行！测试多行！测试多行！测试多行！";
    [chatMsgArray addObject: msg5];
    
    ChatingMsg *msg6 = [ChatingMsg new];
    msg6.fromUserName = @"曹操";
    msg6.toUserName = @"皇叔刘备";
    msg6.msgDirectionType = MSGDirectionTypeSend;
    msg6.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg6.content = @"[图片]";
    msg6.attachID = @"102";
    msg6.attachData = UIImageJPEGRepresentation([UIImage imageNamed: msg6.attachID], 1);
    msg6.attachType = MSGAttachTypeImage;
    [chatMsgArray addObject: msg6];
    
    ChatingMsg *msg6_1 = [ChatingMsg new];
    msg6_1.fromUserName = @"曹操";
    msg6_1.toUserName = @"皇叔刘备";
    msg6_1.msgDirectionType = MSGDirectionTypeSend;
    msg6_1.sendDate = [[NSDate date] timeIntervalSince1970] * 1000;
    msg6_1.content = @"[录音]";
    msg6_1.attachData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"testSong" ofType: @"mp3"]];
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
        MKChatCellContentView *cellView = [[MKChatCellContentView alloc] initWithChatMsg: chatMsgArray[indexPath.row]];
        cellView.indexPath = indexPath;
        cellView.delegate = self;
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
-(void)downLoadData:(NSIndexPath *)indexPath {
    
}

-(void)reviewMemberInfo:(NSIndexPath *)indexPath {
    
}

-(NSArray<NSString *> *)allImageAttachFileParths {
    NSMutableArray *filePaths =@[].mutableCopy;
    for(ChatingMsg *msg in chatMsgArray){
        if(msg.attachType == MSGAttachTypeImage){
            [filePaths addObject: [[NSBundle mainBundle] pathForResource: msg.attachID ofType: @"png"]];
        }
    }
    return filePaths;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
