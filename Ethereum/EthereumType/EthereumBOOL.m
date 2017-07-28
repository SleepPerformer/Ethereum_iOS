//
//  EthereumBOOL.m
//  QuKuai
//
//  Created by 李江浩 on 2016/12/22.
//  Copyright © 2016年 NewDrivers. All rights reserved.
//

#import "EthereumBOOL.h"

@implementation EthereumBOOL
- (NSString *)ethereumBOOL{
    if (_ethereumBOOL == nil) {
        _ethereumBOOL = [[NSString alloc] init];
    }
    return _ethereumBOOL;
}
- (void)initWithBOOL:(NSString *)boolString{
    self.ethereumBOOL = boolString;
}
@end
