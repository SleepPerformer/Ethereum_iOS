//
//  BasicInfoViewController.m
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/27.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "BasicInfoViewController.h"
#import "EthereumContract.h"

@interface BasicInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *privateKeyLabel;

@end

@implementation BasicInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createPrivateKey:(id)sender {
    EthereumContract *contract = [EthereumContract createBasicInfo];
    self.addressLabel.text = contract.from;
    self.privateKeyLabel.text = contract.privateKey;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
