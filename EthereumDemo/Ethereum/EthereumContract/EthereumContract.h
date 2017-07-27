//
//  EthereumContract.h
//  EthereumEncode
//
//  Created by 李江浩 on 2016/12/14.
//  Copyright © 2016年 NewDrivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EthereumContract : NSObject
@property (nonatomic,strong) NSDictionary *dict;
@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *to;
@property (strong, nonatomic) NSString *privateKey;
+ (instancetype)sharedInstance;
+ (instancetype)initWithFromAndTo;
+ (instancetype)initWithPrivateKey:(NSString *)privateKey;

+ (instancetype)createBasicInfo;

- (NSString *)getPayloadWithFunction:(NSString *)funcName andArgs:(NSArray *)arguments andArgsCount:(NSNumber *)count;
- (NSString *)getSignatureWithHash:(NSString *)hash;
- (NSNumber *)getPresentTimestamp;
/**
 把服务器的结果解析出来，字符串的形式存储

 @param result result中的ret字符串
 @param counts 字符串中含有的32字节的个数
 @return 存储结果的数组
 */
#warning 这里需要改，counts没用
- (NSArray *)decodeResult:(NSString *)result returnCounts:(NSNumber *)counts;//不推荐使用
/**
 把服务器的结果解析出来，字符串的形式存储，推荐使用

 @param result result中的ret字符串
 @return 存储结果的数组
 */
- (NSArray *)decodeResult:(NSString *)result;//推荐使用
- (NSString *)decodeStringWithHexString:(NSString *)hexString;
- (NSNumber *)decodeIntWithHexString:(NSString *)hexString;
- (NSNumber *)decodeLongWithHexString:(NSString *)hexString;
- (NSString *)cryptionPublicKey:(NSString *)publicKey;

//index是返回值的索引 0 开始
- (NSString *)getLongStringWithRetArray:(NSArray *)ret byLengthIndex:(NSInteger)index;
@end
