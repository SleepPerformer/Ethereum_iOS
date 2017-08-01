//
//  SPBlockchainType.m
//  EthereumDemo
//
//  Created by 李江浩 on 2017/8/1.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "SPBlockchainType.h"

@implementation SPBlockchainType
#pragma mark - lazy
- (NSString *)type {
    if (_type == nil) {
        _type = [[NSString alloc] init];
    }
    return _type;
}

+ (instancetype)blockchainTypeWithArgument:(NSString *)argument {
    // @"string abc def"  @"array 12,23,23, 23"
    SPBlockchainType *type = [[self alloc] init];
    NSArray *array = [argument componentsSeparatedByString:@" "];
    type.type = [array firstObject];
    // 全部转成小写类型
    NSString *content = [NSString string];
    type.type = [type.type lowercaseString];
    NSUInteger count = [array count];
    content = array[1];
    for (NSUInteger i = 2; i < count; i++) {
        content = [NSString stringWithFormat:@"%@ %@", content, array[i]];
    }
    if ([type.type isEqualToString:@"array"]) {
        // 将字符串转成数组，以逗号作为区分
        NSArray *contents = [content componentsSeparatedByString:@","];
        type.content = contents;
    } else {
        type.content = content;
    }
    return type;
}

@end
