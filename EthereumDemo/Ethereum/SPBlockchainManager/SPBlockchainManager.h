//
//  SPBlockchainManager.h
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/31.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPContractEncoder, SPContractDecoder;

@interface SPBlockchainManager : NSObject
@property (strong, nonatomic) NSDictionary *functionsHash; // 私有应该
/** 用户地址 */
@property (copy, nonatomic, readonly) NSString *from;
/** 合约地址 */
@property (copy, nonatomic) NSString *to;
/** 用户私钥 */
@property (copy, nonatomic, readonly) NSString *privateKey;
/** 编码 */
@property (strong, nonatomic) SPContractEncoder *encoder;
/** 解码 */
@property (strong, nonatomic) SPContractDecoder *decoder;

+ (instancetype)manager;
/**
 根据已有的私钥登录
 
 @param privateKey 用户输入的私钥
 @return SPBlockchainManager实例
 */
+ (instancetype)initWithPrivateKey:(NSString *)privateKey;

/**
 生成所有基本信息
 
 @return SPBlockchainManager实例
 */
+ (instancetype)createBasicInfo;

/**
 获取合约编码
 
 @param funcName 合约方法名
 @param arguments 已封装成专属类型的参数数组
 @return 合约编码字符串
 */
- (NSString *)payloadWithFunction:(NSString *)funcName andArgs:(NSArray<NSString *> *)arguments;
/**
 对调起合约得到的hash值进行签名

 @param hash hash字符串
 @return Objective-C版本的国密signature
 */
- (NSString *)signatureWithHash:(NSString *)hash;
/**
 获得时间戳

 @return 时间戳。类型是NSNumber
 */
- (NSNumber *)presentTimestamp;

@end
