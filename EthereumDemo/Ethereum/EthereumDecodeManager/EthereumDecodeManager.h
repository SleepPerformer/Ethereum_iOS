//
//  EthereumDecodeManager.h
//  QuKuai
//
//  Created by 李江浩 on 2017/6/5.
//  Copyright © 2017年 NewDrivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EthereumDecodeManager : NSObject
- (NSArray *)decodeResult:(NSString *)result returnCounts:(NSNumber *)counts;
- (NSArray *)decodeResult:(NSString *)result;
- (NSString *)getLongStringWithRetArray:(NSArray *)ret byLengthIndex:(NSInteger)index;
- (NSNumber *)decodeIntWithHexString:(NSString *)hexString;
- (NSNumber *)decodeLongWithHexString:(NSString *)hexString;
- (NSString *)decodeStringWithHexString:(NSString *)hexString;
@end
