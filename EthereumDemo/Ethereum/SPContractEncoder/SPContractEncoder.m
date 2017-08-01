//
//  SPContractEncoder.m
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/31.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "SPContractEncoder.h"

@implementation SPContractEncoder
#pragma mark - C_Methods
void toHexString(int value, char ret[]) {
    char stack[65];
    int top = -1;
    while (value != 0) {
        if (value % 16 < 10) {
            stack[++top] = value % 16 + '0';
        } else {
            stack[++top] = value % 16 - 10 + 'a';
        }
        value = value / 16;
    }
    int i = 0;
    while (top != -1) {
        ret[i++] = stack[top--];
    }
    ret[i] = '\0';
}
void convertString(char str[], int strlen) {
    int start = 0;
    int end = strlen - 1;
    while (end > start) {
        char tem;
        tem = str[start];
        str[start++] = str[end];
        str[end--] = tem;
    }
}
void encodeInt256(int value, char ret[]) {
    if (value >= 0) {
        encodeUint256(value, ret);
        return;
    }
    value = -1 * value;
    unsigned short v = (unsigned short)value;
    v = ~v + 1;
    toHexString(v, ret);
    convertString(ret, (int)strlen(ret));
    char tem[65];
    int len = (int)strlen(ret);
    int i = 0;
    for (; i < len; i++) {
        tem[i] = ret[i];
    }
    for (; i < 64; i++) {
        tem[i] = 'f';
    }
    tem[i] = '\0';
    convertString(tem, (int)strlen(tem));
    memcpy(ret, tem, strlen(tem));
    ret[i] = '\0';
}
void encodeUint256(int value, char ret[]) {
    //32个字节，64+1个位置
    toHexString(value,ret);
    convertString(ret, (int)strlen(ret));
    char tem[65];
    int len = (int)strlen(ret);
    int i = 0;
    for (; i < len; i++) {
        tem[i] = ret[i];
    }
    for (; i < 64; i++) {
        tem[i] = '0';
    }
    tem[i] = '\0';
    convertString(tem, (int)strlen(tem));
    memcpy(ret, tem, strlen(tem));
    ret[i] = '\0';
}
#define TRUEPAYLOAD "0000000000000000000000000000000000000000000000000000000000000001\0"
#define FALSEPAYLOAD "0000000000000000000000000000000000000000000000000000000000000000\0"
void encodeBool(char *_bool, char ret[]) {
    char tem[65];
    if (!strcmp(_bool, "true")) {
        strcpy(tem, TRUEPAYLOAD);
    } else{
        strcpy(tem, FALSEPAYLOAD);
    }
    memcpy(ret, tem, strlen(tem));
}
#pragma mark - Encode
- (NSString *)encodeInt256:(int)value resultString:(NSString *)result {
    char *ret = malloc(sizeof(char) * 65);
    encodeInt256(value, ret);
    NSString *string = [NSString stringWithFormat:@"%s",ret];
    free(ret);
    return [NSString stringWithFormat:@"%@%@", result, string];
}

- (NSString *)encodeBool:(NSString *)boolValue resultString:(NSString *)result {
    char *ret = malloc(sizeof(char) * 65);
    if ([boolValue isEqualToString:@"YES"]) {
        encodeBool("true", ret);
        NSString *string = [NSString stringWithFormat:@"%s", ret];
        free(ret);
        return [NSString stringWithFormat:@"%@%@", result, string];
    } else if ([boolValue isEqualToString:@"NO"]){
        encodeBool("false", ret);
        NSString *string = [NSString stringWithFormat:@"%s", ret];
        free(ret);
        return [NSString stringWithFormat:@"%@%@", result, string];
    } else {
        free(ret);
        return nil;
    }
}
#pragma mark - 字符串参数编码
//计算偏移量，都一样
- (NSString *)encodeOffsetWithStaticString:(NSString *)result dynamicString:(NSString *)dynamicString argsCount:(NSInteger)count {
    char *ret = malloc(sizeof(char) * 65);
    unsigned long offset;//偏移量,字节为单位
    offset = count * 32 + dynamicString.length / 64 * 32;
    encodeInt256((int)offset, ret);
    NSString *string = [NSString stringWithFormat:@"%s",ret];
    free(ret);
    return [NSString stringWithFormat:@"%@%@",result,string];
}

- (NSString *)encodeString:(NSString *)stringValue dynamicString:(NSString *)dynamicString {
    //长度编码
    char *dynamicArgs = malloc(sizeof(char) * 65);//申请可以存放20个32字节的内容
    const char *test = [stringValue UTF8String];
    int stringLength = (int)strlen(test);
    encodeInt256(stringLength, dynamicArgs);
    dynamicString = [NSString stringWithFormat:@"%@%s",dynamicString,dynamicArgs];
    free(dynamicArgs);
    //内容编码
    NSData *myD = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for(int i = 0; i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
        if([newHexStr length] == 1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    //先算有几个32字节
    int bytesCount = stringLength / 32 + 1;
    int zeroCount = bytesCount * 64 - (int)hexStr.length;
    //补全n*32字节
    for (int i = 0; i < zeroCount; i++) {
        hexStr = [NSString stringWithFormat:@"%@0",hexStr];
    }
    return [NSString stringWithFormat:@"%@%@",dynamicString,hexStr];
}

- (BOOL)isPureInt:(NSString*)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
- (NSString *)encodeArray:(NSArray <NSString *> *)array dynamicString:(NSString *)dynamicString {
    //长度编码
    char *dynamicArgs = malloc(sizeof(char) * 65);//申请可以存放20个32字节的内容
    int arrayLength = (int)[array count];
    encodeInt256(arrayLength, dynamicArgs);
    dynamicString = [NSString stringWithFormat:@"%@%s", dynamicString, dynamicArgs];
    free(dynamicArgs);
    
    //内容编码,只能对int类型的数字进行编码
    for (int i = 0; i < arrayLength; i++) {
        NSAssert([array[i] isKindOfClass:[NSString class]], @"数组中只能为整形数字字符串");
        NSAssert([self isPureInt:array[i]], @"数组中只能为整形数字字符串");
        int value = [array[i] intValue];
        char *ret = malloc(sizeof(char) * 65);
        encodeInt256(value, ret);
        NSString *string = [NSString stringWithFormat:@"%s",ret];
        free(ret);
        dynamicString = [NSString stringWithFormat:@"%@%@",dynamicString,string];
    }
    return dynamicString;
}
@end
