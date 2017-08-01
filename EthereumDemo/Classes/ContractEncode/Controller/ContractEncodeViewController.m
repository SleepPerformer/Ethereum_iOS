//
//  ContractEncodeViewController.m
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/27.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "ContractEncodeViewController.h"
#import "SPBlockchainManager.h"

@interface ContractEncodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UITextField *functionTextField;
//@property (copy, nonatomic) NSString *result;

@end

@implementation ContractEncodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"合约编码Demo";
    // 合约编码方式，为，方法原型编码+参数编码
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)encodeContract:(id)sender {
    NSString *funcCode = [NSString string];
    SPBlockchainManager *manager = [SPBlockchainManager manager];
    funcCode = [manager.encoder encodeFunction:self.functionTextField.text];
    // 需要进行参数编码 参数类型需要使用专门的类型进行一次封装

    NSString *argsResult = [manager payloadWithFunction:funcCode andArgs:@[@"string 李江浩", @"bool YES"]];
    self.resultLabel.text = [NSString stringWithFormat:@"%@", argsResult];
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
