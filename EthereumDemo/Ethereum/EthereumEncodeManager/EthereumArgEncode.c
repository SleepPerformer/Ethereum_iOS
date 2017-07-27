//
//  EthereumArgEncode.c
//  EthereumABI
//
//  Created by 李江浩 on 2016/12/10.
//  Copyright © 2016年 NewDrivers. All rights reserved.
//

#include "EthereumArgEncode.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define TRUEPAYLOAD "0000000000000000000000000000000000000000000000000000000000000001\0"
#define FALSEPAYLOAD "0000000000000000000000000000000000000000000000000000000000000000\0"
//数字转为16进制字符串
void toHexString(int value, char ret[]) {
    char stack[65];
    int top = -1;
    while (value != 0) {
        if (value%16 < 10) {
            stack[++top] = value%16 + '0';
        } else {
            stack[++top] = value%16 - 10 + 'a';
        }
        value = value/16;
    }
    int i = 0;
    while (top != -1) {
        ret[i++] = stack[top--];
    }
    ret[i] = '\0';
}
//翻转字符串
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

void encodeUint256(int value, char ret[]) {
    //32个字节，64+1个位置
    toHexString(value,ret);
    convertString(ret, (int)strlen(ret));
    char tem[65];
    int len = (int)strlen(ret);
    int i=0;
    for (; i < len; i++) {
        tem[i] = ret[i];
    }
    for (; i<64; i++) {
        tem[i] = '0';
    }
    tem[i] = '\0';
    convertString(tem, (int)strlen(tem));
    memcpy(ret, tem, strlen(tem));
    ret[i] = '\0';
}

void encodeBool(char *_bool, char ret[]) {
    char tem[65];
    if (!strcmp(_bool, "true")) {
        strcpy(tem, TRUEPAYLOAD);
    } else{
        strcpy(tem, FALSEPAYLOAD);
    }
    memcpy(ret, tem, strlen(tem));
}
//字节内容转16进制字符串
void ByteToHexStr(const char* source, char* dest, int sourceLen) {
    short i;
    unsigned char highByte, lowByte;
    for (i = 0; i < sourceLen; i++) {
        highByte = source[i] >> 4;
        lowByte = source[i] & 0x0f;
        highByte += 0x30;
        if (highByte > 0x39)
            dest[i * 2] = highByte + 0x07;
        else
            dest[i * 2] = highByte;
        lowByte += 0x30;
        if (lowByte > 0x39)
            dest[i * 2 + 1] = lowByte + 0x07;
        else
            dest[i * 2 + 1] = lowByte;
    }
    return;  
}

int hexCharToValue(const char ch) {
    int result = 0;
    //获取16进制的高字节位数据
    if(ch >= '0' && ch <= '9') {
        result = (int)(ch - '0');
    } else if (ch >= 'a' && ch <= 'z') {
        result = (int)(ch - 'a') + 10;
    } else if (ch >= 'A' && ch <= 'Z'){
        result = (int)(ch - 'A') + 10;
    }
    else {
        result = -1;
    }
    return result;
}

char valueToHexCh(const int value) {
    char result = '\0';
    if (value >= 0 && value <= 9) {
        result = (char)(value + 48); //48为ascii编码的‘0’字符编码值
    } else if (value >= 10 && value <= 15) {
        result = (char)(value - 10 + 65); //减去10则找出其在16进制的偏移量，65为ascii的'A'的字符编码值
    }
    return result;
}
int strToHex(const char *ch, char *hex) {
    int high,low;
    int tmp = 0;
    if(ch == NULL || hex == NULL){
        return -1;
    }
    if(strlen(ch) == 0){
        return -2;
    }
    while(*ch) {
        tmp = (int)*ch;
        high = tmp >> 4;
        low = tmp & 15;
        *hex++ = valueToHexCh(high); //先写高字节
        *hex++ = valueToHexCh(low); //其次写低字节
        ch++;
    }
    *hex = '\0';
    return 0;
}

unsigned short getbits(unsigned short value) {
    unsigned short z;
    z=value&0100000;
    if(z==0100000)
        z=~value+1;
    else
        z=value;
    return(z);
}
void encodeInt256(int value,char ret[]) {
    if (value >= 0) {
        encodeUint256(value, ret);
        return;
    }
    value = -1 * value;
    unsigned short v = (unsigned short)value;
    ////printf("value 的是%i\n",v);
    v = ~v+1;
    ////printf("value 的补码是%i\n",v);
    toHexString(v,ret);
    convertString(ret, (int)strlen(ret));
    char tem[65];
    int len = (int)strlen(ret);
    int i=0;
    for (; i < len; i++) {
        tem[i] = ret[i];
    }
    for (; i<64; i++) {
        tem[i] = 'f';
    }
    tem[i] = '\0';
    convertString(tem, (int)strlen(tem));
    memcpy(ret, tem, strlen(tem));
    ret[i] = '\0';
}
