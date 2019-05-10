//
//  STNavigatioViewController.m
//  SealRTC
//
//  Created by birney on 2019/4/19.
//  Copyright © 2019 BridgeMind. All rights reserved.
//

#import "STNavigatioViewController.h"

@interface STNavigatioViewController ()

@end

@implementation STNavigatioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

@end
