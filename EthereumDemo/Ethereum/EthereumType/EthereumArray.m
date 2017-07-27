//
//  EthereumArray.m
//  QuKuai
//
//  Created by 李江浩 on 2016/12/22.
//  Copyright © 2016年 NewDrivers. All rights reserved.
//

#import "EthereumArray.h"

@implementation EthereumArray
- (NSArray *)ehtereumArray{
    if (_ehtereumArray == nil) {
        _ehtereumArray = [[NSArray alloc] init];
    }
    return _ehtereumArray;
}
- (void)initWithNSArray:(NSArray *)array{
    self.ehtereumArray = array;
}
@end
