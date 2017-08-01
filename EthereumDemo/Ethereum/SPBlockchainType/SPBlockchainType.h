//
//  SPBlockchainType.h
//  EthereumDemo
//
//  Created by 李江浩 on 2017/8/1.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPBlockchainType : NSObject
/** 参数的内容 可能是数组，也有可能是字符串 */
@property (nonatomic, strong) id content;
/** 合约方法中的类型 */
@property (nonatomic, copy) NSString *type;

+ (instancetype)blockchainTypeWithArgument:(NSString *)argument;

@end
