//
//  EthereumResultDecode.c
//  QuKuai
//
//  Created by 李江浩 on 2017/1/5.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//
#include <stdlib.h>
#include "string.h"
#include "EthereumResultDecode.h"
void analyzeResultCode(char *result, char **ret, int count){
    //这个结果应该是由0x的，直接跳过
    if (result == NULL) {
        return;
    }
    int tureCount = (int)strlen(result)/64;
    for (int i = 0; i<tureCount; i++) {
        //得到32字节的内容
        char *tem = (char *)malloc(sizeof(char)*65);
        for (int j = 0; j<64; j++) {
            tem[j] = result[i*64+2+j];
        }
        tem[64] = '\0';
        ret[i] = tem;
        //free(tem);
    }
    //这里释放会不会有野指针
}
