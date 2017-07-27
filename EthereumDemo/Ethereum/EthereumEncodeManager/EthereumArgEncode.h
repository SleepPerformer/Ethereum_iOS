//
//  EthereumArgEncode.h
//  EthereumABI
//
//  Created by 李江浩 on 2016/12/10.
//  Copyright © 2016年 NewDrivers. All rights reserved.
//

#ifndef EthereumArgEncode_h
#define EthereumArgEncode_h

#include <stdio.h>
//对于现有的接口，参数类型都是int uint bool bytes32 空
/**
 对uint类型的参数进行编码

 @param value 参数的值
 @param ret 编码后的返回值
 */
void encodeUint256(int value,char ret[]);
/**
 对bool类型的参数进行编码

 @param _bool true or false
 @param ret 编码后的返回值
 */
void encodeBool(char *_bool, char ret[]);
/**
 对bytes32类型的参数进行编码

 @param bytes 参数的值
 @param ret 编码后的返回值
 */
//void encodeBytes32(const char *bytes, char ret[]);
//void EncodeBytes32(const char *bytes, char ret[]);
int strToHex(const char *ch, char *hex);
/**
 对函数名进行编码

 @param functionName 方法名+参数类型构成的字符串
 @param ret 加密后的结果前4个字节
 */
//uint8_t* encodeFunction(char* functionName);
/**
 对int32类型进行编码

 @param value 参数的值
 @param ret 编码后返回的值
 */
void encodeInt256(int value, char ret[]);
void encodeString(char *string, char ret[]);
#endif /* EthereumArgEncode_h */
