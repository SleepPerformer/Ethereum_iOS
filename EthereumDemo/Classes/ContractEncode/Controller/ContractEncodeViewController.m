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
//@property (copy, nonatomic) NSString *result;

@end

@implementation ContractEncodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 合约编码方式，为，方法原型编码+参数编码
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)encodeContract:(id)sender {
    NSString *funcResult = [NSString string];
    EthereumEncodeManager *manager = [[EthereumEncodeManager alloc] init];
    funcResult = [manager encodeFunction:self.functionTextField.text];
    // 需要进行参数编码 参数类型需要使用专门的类型进行一次封装
    // string -> EthereumString
    // bool -> EthereumBOOL
    // array -> EthereumArray
    NSArray *array = @[]; // 把封装好的参数放入array中
    NSString *argsResult = [manager encodeArgs:array];
    self.resultLabel.text = [NSString stringWithFormat:@"%@%@", funcResult, argsResult];
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
