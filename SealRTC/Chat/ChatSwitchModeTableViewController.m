//
//  ChatSwitchModeTableViewController.m
//  RongCloud
//
//  Created by Vicky on 2018/7/4.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatSwitchModeTableViewController.h"
#import "RongRTCTalkAppDelegate.h"


@interface ChatSwitchModeTableViewController ()

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation ChatSwitchModeTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:NSClassFromString(@"UITableViewCell") forCellReuseIdentifier:@"cell"];
    self.titleArray = @[NSLocalizedString(@"chat_fluent", nil),NSLocalizedString(@"chat_hd", nil)];
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 15.0);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
}

//- (void)viewWillLayoutSubviews
//{
//    // shift it up
//    CGRect frame = self.view.frame;
//    frame.origin.y = -20;
//    frame.size.height = 100;
//    [self.view setFrame:frame];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    _selectedIndexPath = selectedIndexPath;
    if (selectedIndexPath) {
        [self.tableView reloadData];
    }else{
        _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if (_selectedIndexPath && [_selectedIndexPath isEqual:indexPath]) {
        cell.textLabel.textColor = [UIColor orangeColor];
    }else
        cell.textLabel.textColor = [UIColor blackColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_videModeBlock) {
        if (indexPath.row == 1) {
            _videModeBlock(RongRTC_VideoMode_Highresolution,indexPath);
        }else
            _videModeBlock(RongRTC_VideoMode_Smooth,indexPath);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


@end
