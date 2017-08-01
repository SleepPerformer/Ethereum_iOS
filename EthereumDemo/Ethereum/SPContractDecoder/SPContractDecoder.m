//
//  SPContractDecoder.m
//  EthereumDemo
//
//  Created by 李江浩 on 2017/7/31.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import "SPContractDecoder.h"

@implementation SPContractDecoder
#pragma mark - C_Methods
void analyzeResultCode(char *result, char **ret, int count){
    //这个结果应该是由0x的，直接跳过
    if (result == NULL) {
        return;
    }
    int tureCount = (int)strlen(result) / 64;
    for (int i = 0; i < tureCount; i++) {
        //得到32字节的内容
        char *tem = (char *)malloc(sizeof(char) * 65);
        for (int j = 0; j < 64; j++) {
            tem[j] = result[i * 64 + 2 + j];
        }
        tem[64] = '\0';
        strcpy(ret[i], tem);
        free(tem);
        tem = NULL;
    }
    //这里释放会不会有野指针
}

- (NSArray *)decodeResult:(NSString *)result {
    NSArray *array = [NSArray array];
    char *cStringResult = (char *)[result UTF8String];
    
    int count = (int)result.length / 64;
    
    char **ret = (char **)malloc(sizeof(char *)*count);
    analyzeResultCode(cStringResult, ret, count);
    NSString *str = [NSString string];
    for (int i = 0; i<count; i++) {
        str = [NSString stringWithFormat:@"%s",ret[i]];
        array = [array arrayByAddingObject:str];
    }
    free(ret);
    ret = NULL;
    return array;
}

- (NSString *)decodeStringWithHexString:(NSString *)hexString {
    NSMutableData *resultData = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexString.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString *hexStr = [hexString substringWithRange:range];
        NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [resultData appendBytes:&intValue length:1];
    }
    NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    return result;
}

- (NSNumber *)decodeIntWithHexString:(NSString *)hexString {
    NSString *str = [[NSString alloc] init];
    if ([hexString rangeOfString:@"0x"].location == NSNotFound) {
        str = [NSString stringWithFormat:@"0x%@", hexString];
    } else {
        str = [NSString stringWithFormat:@"%@", hexString];
    }
    BOOL neg = NO;
    char *c_hexString = (char *)[str UTF8String];
    int intValue = 0;
    char numToAlpha[10] = {'f','e','d','c','b','a','9','8','7','6'};
    char alphaToNum[6] = {'5','4','3','2','1','0'};
    if (c_hexString[2] == 'f') {
        //是负数
        neg = YES;
        for (int i = 2; i < 66; i++) {
            if (c_hexString[i] >= '0' && c_hexString[i] <= '9') {
                //是数字
                c_hexString[i] = numToAlpha[(c_hexString[i] - '0')];
            } else {
                //是字母
                c_hexString[i] = alphaToNum[(c_hexString[i] - 'a')];
            }
        }
        
    }
    sscanf(c_hexString, "%x", &intValue);
    if (neg) {
        //是负数
        intValue = -1 * (intValue + 1);
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

- (NSString *)getLongStringWithRetArray:(NSArray *)ret byLengthIndex:(NSInteger)index {
    //先知道偏移量
    NSString *retString = [NSString string];
    int bytesCount = [[self decodeIntWithHexString:ret[index]] intValue] / 32;
    //再知道长度 stringLength
    int stringLength = [[self decodeIntWithHexString:ret[bytesCount]] intValue];
    int number = stringLength / 32 + 1;
    for (int i = 0; i < number; i++) {
        retString = [NSString stringWithFormat:@"%@%@", retString, ret[bytesCount + i + 1]];
    }
    return retString;
}
@end
