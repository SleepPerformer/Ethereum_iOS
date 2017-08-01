//
//  SPContractDecoder.h
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/31.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPContractDecoder : NSObject
/**
 把服务器的结果解析出来，以32字节为最小单位，字符串的形式存储在数组中
 
 @param result result中的ret字符串
 @return 存储结果的数组
 */
- (NSArray *)decodeResult:(NSString *)result;

/**
 16进制返回结果解析成字符串
 
 @param hexString 16进制字符串，可以超过32字节限制
 @return 字符串
 */
- (NSString *)decodeStringWithHexString:(NSString *)hexString;
/**
 16进制返回结果解析成整形数字

 @param hexString 16进制返回结果
 @return 整形数字
 */
- (NSNumber *)decodeIntWithHexString:(NSString *)hexString;
/**
 16进制返回结果解析成长整形数字

 @param hexString 16进制返回结果
 @return 长整形数字
 */
- (NSNumber *)decodeLongWithHexString:(NSString *)hexString;

//index是返回值的索引 0 开始
/**
 将数组汇总

 @param ret 按照32字节为单位存储的结果数组
 @param index 从0开始计算，想解析数组的元素索引
 @return 编码后的字符串
 */
- (NSString *)getLongStringWithRetArray:(NSArray *)ret byLengthIndex:(NSInteger)index;
@end
