//
//  EthereumString.m
//  QuKuai
//
//  Created by 李江浩 on 2016/12/22.
//  Copyright © 2016年 NewDrivers. All rights reserved.
//

#import "EthereumString.h"

@implementation EthereumString
- (NSString *)ethereumString{
    if (_ethereumString == nil) {
        _ethereumString = [[NSString alloc] init];
    }
    return _ethereumString;
}
- (instancetype)initWithNSString:(NSString *)string{
    if (self = [super init]) {
        self.ethereumString = string;
    }
    return self;
}
@end
