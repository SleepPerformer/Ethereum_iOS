//
//  ContractEncodeViewController.m
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/27.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "ContractEncodeViewController.h"
#import "EthereumEncodeManager.h"

@interface ContractEncodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UITextField *functionTextField;

@end

@implementation ContractEncodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)encodeContract:(id)sender {
    EthereumEncodeManager *manager = [[EthereumEncodeManager alloc] init];
    self.resultLabel.text = [manager encodeFunction:self.functionTextField.text];
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
