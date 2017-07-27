//
//  EthereumString.h
//  QuKuai
//
//  Created by 李江浩 on 2016/12/22.
//  Copyright © 2016年 NewDrivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EthereumString : NSObject
@property (nonatomic,strong) NSString *ethereumString;
- (instancetype)initWithNSString:(NSString *)string;
@end
