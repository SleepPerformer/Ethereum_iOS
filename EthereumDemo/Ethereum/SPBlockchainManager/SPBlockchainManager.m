//
//  SPBlockchainManager.m
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/31.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "SPBlockchainManager.h"
#import "SPSecp256k1.h"
#import "SPBlockchainType.h"
#import "SPContractDecoder.h"
#import "SPContractEncoder.h"

@interface SPBlockchainManager()
/** 用户地址 */
@property (copy, nonatomic, readwrite) NSString *from;
@property (copy, nonatomic, readwrite) NSString *privateKey;
@end

static int BytesUnit = 32;
static int BitsUnit  = 64;

@implementation SPBlockchainManager
#pragma mark - singleton
static SPBlockchainManager *instance_ = nil;

//    使用线程保证之执行一次
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        instance_ = [[self alloc] init];
    });
    return instance_;
}
//调用alloc 会自动调用allocWithZone: 防止生成新的实例
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        instance_ = [super allocWithZone:zone];
    });
    return instance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return instance_;
}
#pragma mark - config
- (SPContractDecoder *)decoder {
    if (_decoder == nil) {
        _decoder = [[SPContractDecoder alloc] init];
    }
    return _decoder;
}

- (SPContractEncoder *)encoder {
    if (_encoder == nil) {
        _encoder = [[SPContractEncoder alloc] init];
    }
    return _encoder;
}

- (void)setFrom:(NSString *)from {
    _from = from;
}
#pragma mark privatekey
- (NSString *)createOCPrivateKey {
    char element[16] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
    char c_private[BitsUnit + 1];
    //随机生成一个数字
    for (int i = 0; i<BitsUnit; i++) {
        int random = arc4random()%16;
        c_private[i] = element[random];
        //NSLog(@"%s",c_private);
    }
    c_private[BitsUnit] = '\0';
    NSString *privateKey = [NSString stringWithFormat:@"0x%s",c_private];
    return privateKey;
}
#pragma mark address
// 通过私钥得到公钥，根据公钥创建地址
- (NSString *)createAddress {
    //先得到公钥
    NSString *addressString = @"0x";
    int *publicKeyLength = (int *)malloc(sizeof(int));
    unsigned char *publicKey = (unsigned char *)malloc(sizeof(unsigned char)*(BitsUnit + 1));
    unsigned char *newPublicKey = (unsigned char *)malloc(sizeof(unsigned char)*BitsUnit);
    secp256k1_context_t *ctx_sign = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
    uint8_t c_private[BytesUnit];
    NSAssert(self.privateKey != nil, @"私钥为空");
    NSString *no0xPrivateString = [self.privateKey substringFromIndex:2];
    NSMutableData* dataPrivate = [NSMutableData data];
    for (int idx = 0; idx +2 <= no0xPrivateString.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [no0xPrivateString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [dataPrivate appendBytes:&intValue length:1];
    }
    Byte * privateByte = (Byte *)[dataPrivate bytes];
    for (int i = 0 ; i < BytesUnit; i++) {
        c_private[i] = privateByte[i];
    }
    if (secp256k1_ec_pubkey_create(ctx_sign, publicKey, publicKeyLength, c_private, 0)) {
        //说明生成有效的公钥
        for (int i = 0; i < BitsUnit; i++) {
            newPublicKey[i] = publicKey[i+1];
        }
        //int32_t size = (int)strlen((char *)newPublicKey);
        int32_t size = BitsUnit;
        int32_t *psize = &size;
        uint8_t *newmessage = (unsigned char *)malloc(sizeof(unsigned char)*200);
        newmessage = sponge(newPublicKey,*psize);
        for (int32_t i = 12; i < 32; i++) {
            addressString = [NSString stringWithFormat:@"%@%.2x",addressString,*(newmessage+i)];
        }
    }
    secp256k1_context_destroy(ctx_sign);
    return addressString;
}

+ (instancetype)createBasicInfo {
    SPBlockchainManager *manager = [SPBlockchainManager manager];
    manager.privateKey = [manager createOCPrivateKey];
    manager.from = [manager createAddress];
    return manager;
}

#pragma mark - login
+ (instancetype)initWithPrivateKey:(NSString *)privateKey {
    SPBlockchainManager *manager = [SPBlockchainManager manager];
    manager.privateKey = privateKey;
    manager.from = [manager createAddress];
//    manager.to = TO;
    return manager;
}
#pragma mark - contract
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
    payload = [NSString stringWithFormat:@"%@",self.functionsHash[funcName]];//方法名的hash
    //如果方法名有误终止
    if ([payload isEqualToString:@"(null)"]) {
        //抛异常
        @throw exception;
    }
    return payload;
}

- (NSString *)payloadWithFunction:(NSString *)funcName andArgs:(NSArray<NSString *> *)arguments {
    __block NSString *result = [self findMethod:funcName];
    __block NSString *ocDynamicArgs = [[NSString alloc]init];//动态参数拼接的结果
    //按顺序遍历数组，进行参数编码，每次产生一个ret都要进行一次字符串的拼接
    char *ret = malloc(sizeof(char) * (BitsUnit + 1));//存放静态参数的编码
    char *dynamicArgs = malloc(sizeof(char) * (BitsUnit + 1));//申请可以存放20个32字节的内容
    NSInteger count = [arguments count];
    for (NSInteger i = 0; i < count; i++) {
        // 自动封装成blockchain类型
        SPBlockchainType *argument = [SPBlockchainType blockchainTypeWithArgument:arguments[i]];
        // 判断是否是 整形，BOOL，字符串，数组(未完成)
        if ([argument.type containsString:@"int"]) {
            result = [self.encoder encodeInt256:[argument.content intValue] resultString:result];
        } else if ([argument.type containsString:@"bool"]) {
            result = [self.encoder encodeBool:argument.content resultString:result];
        } else if ([argument.type containsString:@"string"]) {
            result = [self.encoder encodeOffsetWithStaticString:result dynamicString:ocDynamicArgs argsCount:count];
            ocDynamicArgs = [self.encoder encodeString:argument.content dynamicString:ocDynamicArgs];
        } else if ([argument.type containsString:@"array"]) {
            // 添加偏移量
            result = [self.encoder encodeOffsetWithStaticString:result dynamicString:ocDynamicArgs argsCount:count];
            ocDynamicArgs = [self.encoder encodeArray:argument.content dynamicString:ocDynamicArgs];
        }
    }
    result = [NSString stringWithFormat:@"%@%@", result, ocDynamicArgs];
    free(ret);
    free(dynamicArgs);
    return result;
}
#pragma mark - signature
- (NSString *)signatureWithHash:(NSString *)hash {
    //    char *cStringSignHash = (char *)[hash UTF8String];
    NSString *signature = @"0x00";
    //转变成c语言的字符串，并把字符串转为 ‘\x’ 形式
    uint8_t p_hash[BytesUnit];
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
    for (int i = 0 ; i < BytesUnit; i++) {
        p_hash[i] = myByte[i];
    }
    secp256k1_context_t *ctx_sign = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
    uint8_t *c_private = (uint8_t *)malloc(sizeof(uint8_t) * BytesUnit);
    NSAssert(self.privateKey != nil, @"私钥为空");
    NSString *no0xPrivateString = [self.privateKey substringFromIndex:2];
    NSMutableData* dataPrivate = [NSMutableData data];
    for (int idx = 0; idx + 2 <= no0xPrivateString.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString *hexStr = [no0xPrivateString substringWithRange:range];
        NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [dataPrivate appendBytes:&intValue length:1];
    }
    Byte * privateByte = (Byte *)[dataPrivate bytes];
    for (int i = 0 ; i < BytesUnit; i++) {
        c_private[i] = privateByte[i];
    }
    uint8_t p_privateKey2[BytesUnit];
    for (int i = 0; i < BytesUnit; i++) {
        p_privateKey2[i] = c_private[i];
    }
    unsigned char *c_signature = malloc(sizeof(unsigned char) * 100);

    //生成签名
    int *recid = malloc(sizeof(int));
    
    if (secp256k1_ecdsa_sign_compact(ctx_sign, p_hash, c_signature, p_privateKey2, NULL, NULL, recid)){
        for (int index = 0; index < BitsUnit; index++) {
            signature = [NSString stringWithFormat:@"%@%.2x", signature,c_signature[index]];
        }
    }
    signature = [NSString stringWithFormat:@"%@%.2x", signature, *recid];
    
    //销毁上下文
    secp256k1_context_destroy(ctx_sign);
    return signature;
}
#pragma mark - timestamp
- (NSNumber *)presentTimestamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = ([dat timeIntervalSince1970]) * 100000;
    long long timestamping = a;
    NSNumber *timestamp = [NSNumber numberWithLongLong:timestamping];
    return timestamp;
}
@end
