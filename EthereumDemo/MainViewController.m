//
//  MainViewController.m
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/27.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "MainViewController.h"
#import "BasicInfoViewController.h"
#import "ContractEncodeViewController.h"

#import "SPBlockchainType.h"
@interface MainViewController ()

@property (nonatomic, strong) NSMutableArray *functions;
@property (nonatomic, strong) NSMutableArray *viewControllerNames;
@end

@implementation MainViewController
- (NSMutableArray *)functions {
    if (_functions == nil) {
        _functions = [[NSMutableArray alloc] init];
        [_functions addObjectsFromArray:@[@"生成私钥以及地址", @"合约编码", @"结果解析"]];
    }
    return _functions;
}

- (NSMutableArray *)viewControllerNames {
    if (_viewControllerNames == nil) {
        _viewControllerNames = [[NSMutableArray alloc] init];
        [_viewControllerNames addObjectsFromArray:@[@"BasicInfoViewController", @"ContractEncodeViewController", @"ResultDecodeViewController"]];
    }
    return _viewControllerNames;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Demo功能展示";
    SPBlockchainType *type = [SPBlockchainType blockchainTypeWithArgument:@"array 12,23,23, 23"];
    NSLog(@"%@", type);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.functions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.functions[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [[NSClassFromString(self.viewControllerNames[indexPath.row]) alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
