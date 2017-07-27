//
//  EthereumDecodeManager.m
//  QuKuai
//
//  Created by 李江浩 on 2017/6/5.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "EthereumDecodeManager.h"
#include "EthereumResultDecode.h"

@implementation EthereumDecodeManager
- (NSArray *)decodeResult:(NSString *)result returnCounts:(NSNumber *)counts {
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
- (NSArray *)decodeResult:(NSString *)result {
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
- (NSString *)getLongStringWithRetArray:(NSArray *)ret byLengthIndex:(NSInteger)index {
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
@end
