//
//  EthereumEncodeManager.m
//  QuKuai
//
//  Created by 李江浩 on 2017/5/2.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "EthereumEncodeManager.h"
#import "EthereumType.h"
#include "EthereumArgEncode.h"

#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdlib.h>
#include <string.h>
#include "round.h"
#include "sponge.h"

#define unit_encode 64

@implementation EthereumEncodeManager

- (NSString *)encodeArgs:(NSArray *)arguments {
    __block NSString *result = [NSString string];
    __block NSString *ocDynamicArgs = [[NSString alloc]init];//动态参数拼接的结果
    NSNumber *count = [NSNumber numberWithInteger:[arguments count]];
    //按顺序遍历数组，进行参数编码，每次产生一个ret都要进行一次字符串的拼接
    char *ret = malloc(sizeof(char)*(unit_encode + 1));//存放静态参数的编码
    char *dynamicArgs = malloc(sizeof(char)*(unit_encode + 1));//申请可以存放20个32字节的内容
    for (int i = 0; i< [arguments count]; i++) {
        if ([arguments[i] isKindOfClass:[NSNumber class]]) {
            NSNumber *num = arguments[i];
            result = [self encodeInt256:[num intValue] resultString:result];
        } else if ([arguments[i] isKindOfClass:[EthereumBOOL class]]) {
            EthereumBOOL *EBOOL = arguments[i];
            result = [self encodeBool:EBOOL.ethereumBOOL resultString:result];
        } else if ([arguments[i] isKindOfClass:[EthereumString class]]){
            //先计算当前的长度
            EthereumString *string = arguments[i];
            result = [self encodeOffsetWithStaticString:result dynamicString:ocDynamicArgs argsCount:count];
            ocDynamicArgs = [self encodeString:string.ethereumString dynamicString:ocDynamicArgs];
        } else if ([arguments[i] isKindOfClass:[EthereumArray class]]) {
            //先计算偏移量
            EthereumArray *array = arguments[i];
            result = [self encodeOffsetWithStaticString:result dynamicString:ocDynamicArgs argsCount:count];
            ocDynamicArgs = [self encodeArray:array.ehtereumArray dynamicString:ocDynamicArgs];
        }
    }
    result = [NSString stringWithFormat:@"%@%@",result,ocDynamicArgs];
    free(ret);
    free(dynamicArgs);
    return result;
}
- (NSString *)encodeFunction:(NSString *)function {
    NSString *encodeFunStr = @"0x";
    uint8_t *newmessage = (uint8_t *)malloc(sizeof(uint8_t)*200); // 这里大小随意写的
    int32_t size = (int)strlen([function UTF8String]);;
    int32_t *psize = &size;
    newmessage = sponge((uint8_t *)[function UTF8String],*psize);
    
    for (int32_t i=0; i<4; i++) {
        encodeFunStr = [NSString stringWithFormat:@"%@%.2x",encodeFunStr,*(newmessage+i)];
    }
    return encodeFunStr;
}

- (NSString *)encodeInt256:(int)value resultString:(NSString *)result {
    char *ret = malloc(sizeof(char)*(unit_encode + 1));
    encodeInt256(value, ret);
    NSString *string = [NSString stringWithFormat:@"%s",ret];
    free(ret);
    return [NSString stringWithFormat:@"%@%@",result,string];
}
- (NSString *)encodeBool:(NSString *)boolValue resultString:(NSString *)result {
    char *ret = malloc(sizeof(char)*(unit_encode + 1));
    if ([boolValue isEqualToString:@"YES"]) {
        encodeBool("true", ret);
        NSString *string = [NSString stringWithFormat:@"%s",ret];
        free(ret);
        return [NSString stringWithFormat:@"%@%@",result,string];
    } else if ([boolValue isEqualToString:@"NO"]){
        encodeBool("false", ret);
        NSString *string = [NSString stringWithFormat:@"%s",ret];
        free(ret);
        return [NSString stringWithFormat:@"%@%@",result,string];
    } else {
        free(ret);
        return nil;
    }
}
#pragma mark - 字符串参数编码
//计算偏移量，都一样
- (NSString *)encodeOffsetWithStaticString:(NSString *)result dynamicString:(NSString *)dynamicString argsCount:(NSNumber *)count {
    char *ret = malloc(sizeof(char)*(unit_encode + 1));
    unsigned long offset;//偏移量,字节为单位
    offset = [count intValue]*unit_encode/2 + dynamicString.length/2;
    encodeInt256((int)offset, ret);
    NSString *string = [NSString stringWithFormat:@"%s",ret];
    free(ret);
    return [NSString stringWithFormat:@"%@%@",result,string];
}
- (NSString *)encodeString:(NSString *)stringValue dynamicString:(NSString *)dynamicString {
    //长度编码
    char *dynamicArgs = malloc(sizeof(char)*(unit_encode + 1));//申请可以存放20个32字节的内容
    const char *test = [stringValue UTF8String];
    int stringLength = (int)strlen(test);
    encodeInt256(stringLength, dynamicArgs);
    dynamicString = [NSString stringWithFormat:@"%@%s",dynamicString,dynamicArgs];
    free(dynamicArgs);
    //内容编码
    NSData *myD = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0; i<[myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    //先算有几个32字节
    int bytesCount = stringLength/unit_encode/2 + 1;
    int zeroCount = bytesCount*unit_encode - (int)hexStr.length;
    //补全n*32字节
    for (int i = 0; i<zeroCount; i++) {
        hexStr = [NSString stringWithFormat:@"%@0",hexStr];
    }
    return [NSString stringWithFormat:@"%@%@",dynamicString,hexStr];
}
- (BOOL)isPureInt:(NSString*)string {
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
- (NSString *)encodeArray:(NSArray <NSString *>*)array dynamicString:(NSString *)dynamicString {
    //长度编码
    char *dynamicArgs = malloc(sizeof(char)*(unit_encode + 1));//申请可以存放20个32字节的内容
    int arrayLength = (int)[array count];
    encodeInt256(arrayLength, dynamicArgs);
    dynamicString = [NSString stringWithFormat:@"%@%s",dynamicString,dynamicArgs];
    free(dynamicArgs);
    
    //内容编码,只能对int类型的数字进行编码
    for (int i = 0; i<arrayLength; i++) {
        NSAssert([array[i] isKindOfClass:[NSString class]], @"数组中只能为整形数字字符串");
        NSAssert([self isPureInt:array[i]], @"数组中只能为整形数字字符串");
        int value = [array[i] intValue];
        char *ret = malloc(sizeof(char)*(unit_encode + 1));
        encodeInt256(value, ret);
        NSString *string = [NSString stringWithFormat:@"%s",ret];
        free(ret);
        dynamicString = [NSString stringWithFormat:@"%@%@",dynamicString,string];
    }
    return dynamicString;
}
@end
