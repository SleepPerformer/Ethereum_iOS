//
//  ResultDecodeViewController.m
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/27.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "ResultDecodeViewController.h"
#import "SPBlockchainManager.h"

@interface ResultDecodeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *decodeContent;
@property (weak, nonatomic) IBOutlet UILabel *decodeResultLabel;

@end

@implementation ResultDecodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)numberDecode:(id)sender {
    SPBlockchainManager *manager = [SPBlockchainManager manager];
    self.decodeResultLabel.text = [NSString stringWithFormat:@"%@", [manager.decoder decodeIntWithHexString:self.decodeContent.text]];
}
- (IBAction)boolDecode:(id)sender {
    SPBlockchainManager *manager = [SPBlockchainManager manager];
    NSNumber *num = [manager.decoder decodeIntWithHexString:self.decodeContent.text];
    if ([num integerValue] == 0) {
        self.decodeResultLabel.text = @"false";
    } else {
        self.decodeResultLabel.text = @"true";
    }
}
- (IBAction)stringDecode:(id)sender {
    SPBlockchainManager *manager = [SPBlockchainManager manager];
    self.decodeResultLabel.text = [NSString stringWithFormat:@"%@", [manager.decoder decodeStringWithHexString:self.decodeContent.text]];
}
- (IBAction)arrayDecode:(id)sender {
    SPBlockchainManager *manager = [SPBlockchainManager manager];
    self.decodeResultLabel.text = [NSString stringWithFormat:@"%@", [manager.decoder decodeResult:self.decodeContent.text]];
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
