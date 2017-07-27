//
//  EthereumContract.m
//  EthereumEncode
//
//  Created by 李江浩 on 2016/12/14.
//  Copyright © 2016年 NewDrivers. All rights reserved.
//

#import "EthereumContract.h"
#import "EthereumType.h"
#import "EthereumEncodeManager.h"

#include "EthereumResultDecode.h"
#include "EthereumArgEncode.h"
#include "secp256k1.h"

#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdlib.h>
#include <string.h>
#include "round.h"
#include "sponge.h"
#define TO @"0xc6261f86e50529e99447cfb7ee043302e902b809"
@interface EthereumContract()
@property (nonatomic, strong) EthereumEncodeManager *encodeManager;
//@property (nonatomic, strong) EthereumDecodeManager *decodeManager;
@end
@implementation EthereumContract

static EthereumContract *instance_ = nil;

//    使用线程保证之执行一次
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    return instance_;
}
//调用alloc 会自动调用allocWithZone: 防止生成新的实例
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [super allocWithZone:zone];
        instance_.from = [[NSString alloc] init];
        instance_.to = [[NSString alloc] init];

        instance_.to = TO;
        instance_.dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          
                          @"0x77f2d86e", @"passengerSubmitOrder",
                          @"0xcf3ee943", @"passengerPrepayFee",
                          @"0xf37beafd", @"getDriverState",
                          @"0xe0eb769a", @"getPassengerState",
                          @"0xf4040f74", @"getDriverOrderPool",
                          @"0x702f1944", @"getOrderID",
                          @"0x7a42dfbe", @"getNearDrivers",//新加
                          @"0xe15199fe", @"passengerCancelOrder",
                          @"0xe0d2d04a", @"passengerJudge",
                          @"0xe4cd2588", @"getJudge",
                          @"0x6896fabf", @"getAccountBalance",
                          @"0x96e79a96", @"getOrderDisAndActFee",
                          @"0x755b71f9", @"getPassStateAndDriverPos",
                          @"0x948f0d94", @"updatePassengerPos",
                          @"0xa5c9183e", @"calculatePreFee",
                          @"0x25ebc00c", @"calculatePreFeeWithPenatly",
                          @"0xdf738676", @"getOrderPreFee",
                          @"0x6726cbf7", @"getOrderActFee",
                          @"0x810bd6af", @"getOrderState",
                          @"0x5c2d8b8a", @"getOrderDrivInfo",
                          @"0x86adebba", @"getNearDrivers",
                          @"0x476b9da0", @"getOrderInfo0",
                          @"0xb126f37b", @"getOrderFeeStimeAndPlaceName",
                          
                          @"0x1d725c22", @"driverFinishOrderWithRoute",
                          @"0x0bbecd8f", @"getOrderDriver",
                          nil];
    });
    return instance_;
}

- (id)copyWithZone:(NSZone *)zone{
    return instance_;
}
+ (instancetype)initWithPrivateKey:(NSString *)privateKey{
    EthereumContract *manager = [EthereumContract sharedInstance];
    manager.privateKey = privateKey;
    manager.from = [manager createAddress];
    manager.to = TO;
    return manager;
}

+ (instancetype)createBasicInfo {
    EthereumContract *manager = [EthereumContract sharedInstance];
    manager.privateKey = [manager createOcPrivateKey];
    manager.from = [manager createAddress];
    return manager;
}

+ (instancetype)initWithFromAndTo {
    EthereumContract *manager = [EthereumContract sharedInstance];
    manager.privateKey = [manager createOcPrivateKey];
    manager.from = [manager createAddress];
    manager.to = TO;
    return manager;
}
- (EthereumEncodeManager *)encodeManager{
    if (_encodeManager == nil) {
        _encodeManager = [[EthereumEncodeManager alloc] init];
    }
    return _encodeManager;
}
#pragma mark - payload
- (NSString *)findMethod:(NSString *)funcName {
    NSString *payload = [[NSString alloc]init];//最终payload的结果
    //可以给NSexception添加category，捕获一些异常
    //异常的名称
    NSString *exceptionName = @"FunctionName may be wrong";
    //异常的原因
    NSString *exceptionReason = @"No this function. Please check";
    //异常的信息
    NSDictionary *exceptionUserInfo = nil;
    
    NSException *exception = [NSException exceptionWithName:exceptionName reason:exceptionReason userInfo:exceptionUserInfo];
    //得到对应的方法签名
    //理想的情况
    //char  *cString=[funcName  UTF8String]; sha3_256(cString);
    //现在只能写死，把函数名和对应的签名hash值放入字典中
    payload = [NSString stringWithFormat:@"%@",self.dict[funcName]];//方法名的hash
    //如果方法名有误终止
    if ([payload isEqualToString:@"(null)"]) {
        //抛异常
        @throw exception;
    }
    return payload;
}
- (NSString *)getPayloadWithFunction:(NSString *)funcName andArgs:(NSArray *)arguments andArgsCount:(NSNumber *)count {
    __block NSString *result = [self findMethod:funcName];
    __block NSString *ocDynamicArgs = [[NSString alloc]init];//动态参数拼接的结果
    //按顺序遍历数组，进行参数编码，每次产生一个ret都要进行一次字符串的拼接
    char *ret = malloc(sizeof(char)*65);//存放静态参数的编码
    char *dynamicArgs = malloc(sizeof(char)*65);//申请可以存放20个32字节的内容
    for (int i = 0; i< [arguments count]; i++) {
        if ([arguments[i] isKindOfClass:[NSNumber class]]) {
            NSNumber *num = arguments[i];
            result = [self.encodeManager encodeInt256:[num intValue] resultString:result];
        } else if ([arguments[i] isKindOfClass:[EthereumBOOL class]]) {
            EthereumBOOL *EBOOL = arguments[i];
            result = [self.encodeManager encodeBool:EBOOL.ethereumBOOL resultString:result];
        } else if ([arguments[i] isKindOfClass:[EthereumString class]]){
            //先计算当前的长度
            EthereumString *string = arguments[i];
            result = [self.encodeManager encodeOffsetWithStaticString:result dynamicString:ocDynamicArgs argsCount:count];
            ocDynamicArgs = [self.encodeManager encodeString:string.ethereumString dynamicString:ocDynamicArgs];
        } else if ([arguments[i] isKindOfClass:[EthereumArray class]]) {
            //先计算偏移量
            EthereumArray *array = arguments[i];
            result = [self.encodeManager encodeOffsetWithStaticString:result dynamicString:ocDynamicArgs argsCount:count];
            ocDynamicArgs = [self.encodeManager encodeArray:array.ehtereumArray dynamicString:ocDynamicArgs];
        }
    }
    result = [NSString stringWithFormat:@"%@%@",result,ocDynamicArgs];
    free(ret);
    free(dynamicArgs);
    return result;
}
#pragma mark - sign
//把C语言的签名转化为OC字符串，并且添加0x
- (NSString *)getSignatureWithHash:(NSString *)hash {
//    char *cStringSignHash = (char *)[hash UTF8String];
    NSString *OCSignature = @"0x00";
    //转变成c语言的字符串，并把字符串转为 ‘\x’ 形式
    uint8_t p_hash[32];
    hash = [hash substringFromIndex:2];
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hash.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hash substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    Byte * myByte = (Byte *)[data bytes];
    for (int i = 0 ; i<32; i++) {
        p_hash[i] = myByte[i];
    }
    secp256k1_context_t *ctx_sign = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
    uint8_t *c_private = (uint8_t *)malloc(sizeof(uint8_t)*32);
    NSAssert(self.privateKey != nil, @"私钥为空");
    NSString *no0xPrivateString = [self.privateKey substringFromIndex:2];
    NSMutableData* dataPrivate = [NSMutableData data];
    for (int idx = 0; idx+2<=no0xPrivateString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [no0xPrivateString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [dataPrivate appendBytes:&intValue length:1];
    }
    Byte * privateByte = (Byte *)[dataPrivate bytes];
    for (int i = 0 ; i<32; i++) {
        c_private[i] = privateByte[i];
    }
    uint8_t p_privateKey2[32];
    for (int i=0; i<32; i++) {
        p_privateKey2[i] = c_private[i];
    }
    unsigned char *signature = malloc(sizeof(unsigned char)*100);

//    *siglen = 100;
    //生成签名
    int *recid = malloc(sizeof(int));
    
    if (secp256k1_ecdsa_sign_compact(ctx_sign, p_hash, signature, p_privateKey2, NULL, NULL, recid)){
        for (int index=0; index<64; index++) {
            OCSignature = [NSString stringWithFormat:@"%@%.2x",OCSignature,signature[index]];
        }
    }
    OCSignature = [NSString stringWithFormat:@"%@%.2x",OCSignature,*recid];
    
    //销毁上下文
    secp256k1_context_destroy(ctx_sign);
    return OCSignature;
}
- (NSNumber *)getPresentTimestamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = ([dat timeIntervalSince1970])*100000;
    long long timestamping = a;
    NSNumber *timestamp = [NSNumber numberWithLongLong:timestamping];
    return timestamp;
}
#pragma mark - 解析返回值
- (NSArray *)decodeResult:(NSString *)result {
//    return [self.decodeManager decodeResult:result];
    NSArray *array = [NSArray array];
    char *cStringResult = (char *)[result UTF8String];
    
    int count = (int)result.length/64;
    
    char **ret = (char **)malloc(sizeof(char *)*count);
    analyzeResultCode(cStringResult, ret, count);
    NSString *str = [NSString string];
    for (int i = 0; i<count; i++) {
        str = [NSString stringWithFormat:@"%s",ret[i]];
        array = [array arrayByAddingObject:str];
    }
    free(ret);
    return array;
}
- (NSArray *)decodeResult:(NSString *)result returnCounts:(NSNumber *)counts {
//    return [self.decodeManager decodeResult:result returnCounts:counts];
    //建议使用decodeResult:
    NSArray *array = [NSArray array];
    char *cStringResult = (char *)[result UTF8String];
    int count = [counts intValue];
    count = (int)result.length/64;
    
    char **ret = (char **)malloc(sizeof(char *)*count);
    analyzeResultCode(cStringResult, ret, count);
    NSString *str = [NSString string];
    for (int i = 0; i<count; i++) {
        str = [NSString stringWithFormat:@"%s",ret[i]];
        array = [array arrayByAddingObject:str];
    }
    free(ret);
    return array;
}
- (NSString *)getLongStringWithRetArray:(NSArray *)ret byLengthIndex:(NSInteger)index {
//    return [self.decodeManager getLongStringWithRetArray:ret byLengthIndex:index];
    //先知道偏移量
    NSString *retString = [NSString string];
    int bytesCount = [[self decodeIntWithHexString:ret[index]] intValue] / 32;
    //再知道长度 stringLength
    int stringLength = [[self decodeIntWithHexString:ret[bytesCount]] intValue];
    int number = stringLength/32 + 1;
    for (int i = 0; i<number; i++) {
        retString = [NSString stringWithFormat:@"%@%@",retString,ret[bytesCount + i + 1]];
    }
    return retString;
}
- (NSNumber *)decodeIntWithHexString:(NSString *)hexString{
//    return [self.decodeManager decodeIntWithHexString:hexString];
    NSString *str = [[NSString alloc] init];
    if ([hexString rangeOfString:@"0x"].location == NSNotFound) {
        str = [NSString stringWithFormat:@"0x%@",hexString];
    } else {
        str = [NSString stringWithFormat:@"%@",hexString];
    }
    BOOL neg = NO;
    char *c_hexString = [str UTF8String];
    int intValue = 0;
    char numToAlpha[10] = {'f','e','d','c','b','a','9','8','7','6'};
    char alphaToNum[6] = {'5','4','3','2','1','0'};
    if (c_hexString[2] == 'f') {
        //是负数
        neg = YES;
        for (int i = 2; i < 66; i++) {
            if (c_hexString[i]>='0' && c_hexString[i]<='9') {
                //是数字
                c_hexString[i] = numToAlpha[(c_hexString[i] - '0')];
            } else {
                //是字母
                c_hexString[i] = alphaToNum[(c_hexString[i] - 'a')];
            }
        }
        
    }
    sscanf(c_hexString,"%x",&intValue);
    if (neg) {
        //是负数
        intValue = -1*(intValue+1);
    }
    NSNumber *num = [NSNumber numberWithInt:intValue];
    return num;
}
- (NSNumber *)decodeLongWithHexString:(NSString *)hexString {
//    return [self.decodeManager decodeLongWithHexString:hexString];
    NSString *str = [[NSString alloc] init];
    if ([hexString rangeOfString:@"0x"].location == NSNotFound) {
        str = [NSString stringWithFormat:@"0x%@",hexString];
    } else {
        str = [NSString stringWithFormat:@"%@",hexString];
    }
    const char *c_hexString = [str UTF8String];
    long longValue = 0;
    sscanf(c_hexString,"%lx",&longValue);
    NSNumber *num = [NSNumber numberWithLong:longValue];
    return num;
}
- (NSString *)decodeStringWithHexString:(NSString *)hexString {
//    return [self.decodeManager decodeStringWithHexString:hexString];
    //想办法把字符串内容转成NSData
    NSMutableData* resultData = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [resultData appendBytes:&intValue length:1];
    }
    NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    return result;
}
#pragma mark - 私钥相关方法
void createPrivateKey(unsigned char *privateKeyData) {
    char element[16] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
    char c_private[65];
    //随机生成一个数字
    for (int i = 0; i<64; i++) {
        int random = arc4random()%16;
        c_private[i] = element[random];
        //NSLog(@"%s",c_private);
    }
    c_private[64] = '\0';
    NSString *privateKey = [NSString stringWithFormat:@"0x%s",c_private];
    privateKey = [privateKey substringFromIndex:2];
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= privateKey.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [privateKey substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    Byte * myByte = (Byte *)[data bytes];
    for (int i = 0 ; i<64; i++) {
        privateKeyData[i] = myByte[i];
    }
    //生成的是32字节的密钥，不是字符串
}
- (NSString *)createOcPrivateKey {
    char element[16] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
    char c_private[65];
    //随机生成一个数字
    for (int i = 0; i<64; i++) {
        int random = arc4random()%16;
        c_private[i] = element[random];
        //NSLog(@"%s",c_private);
    }
    c_private[64] = '\0';
    NSString *privateKey = [NSString stringWithFormat:@"0x%s",c_private];

    return privateKey;
}
//从文件中得到私钥
- (NSString *)getPrivateKeyFromFile:(NSString *)filePath {
    NSString *privateString = [[NSString alloc] init];
    return privateString;
}
- (NSString *)cryptionPublicKey:(NSString *)publicKey {
    //先把0x123105 转为 '0x12','0x31','0x05'
    //是有0x开头的
    char publicKeyData[64];
    publicKey = [publicKey substringFromIndex:2];
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= publicKey.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [publicKey substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    Byte * myByte = (Byte *)[data bytes];
    for (int i = 0 ; i<64; i++) {
        publicKeyData[i] = myByte[i];
    }
    
    int32_t size = (int)strlen(publicKeyData);
    int32_t *psize = &size;
    uint8_t *newmessage = (unsigned char *)malloc(sizeof(unsigned char)*200);
    newmessage=sponge((unsigned char *)publicKeyData,*psize);
    NSString *addressString = @"0x";
    for (int32_t i=12; i<32; i++) {
        addressString = [NSString stringWithFormat:@"%@%.2x",addressString,*(newmessage+i)];
    }
    return addressString;
}
- (NSString *)createAddress {
    //先得到公钥
    NSString *addressString = @"0x";
    int *publicKeyLength = (int *)malloc(sizeof(int));
    unsigned char *publicKey = (unsigned char *)malloc(sizeof(unsigned char)*65);
    unsigned char *newPublicKey = (unsigned char *)malloc(sizeof(unsigned char)*64);
    secp256k1_context_t *ctx_sign = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
    uint8_t c_private[32];
    NSAssert(self.privateKey != nil, @"私钥为空");
    NSString *no0xPrivateString = [self.privateKey substringFromIndex:2];
    NSMutableData* dataPrivate = [NSMutableData data];
    for (int idx = 0; idx+2 <= no0xPrivateString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [no0xPrivateString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [dataPrivate appendBytes:&intValue length:1];
    }
    Byte * privateByte = (Byte *)[dataPrivate bytes];
    for (int i = 0 ; i<32; i++) {
        c_private[i] = privateByte[i];
    }
    if (secp256k1_ec_pubkey_create(ctx_sign, publicKey, publicKeyLength, c_private, 0)) {
        //说明生成有效的公钥
        for (int i = 0; i<64; i++) {
            newPublicKey[i] = publicKey[i+1];
        }
        int32_t size = (int)strlen((char *)newPublicKey);
//        int32_t size = 64;
        int32_t *psize = &size;
        uint8_t *newmessage = (unsigned char *)malloc(sizeof(unsigned char)*200);
        newmessage=sponge(newPublicKey,*psize);
        for (int32_t i=12; i<32; i++) {
            addressString = [NSString stringWithFormat:@"%@%.2x",addressString,*(newmessage+i)];
        }
    }
    secp256k1_context_destroy(ctx_sign);
    return addressString;
}
@end
