//
//  UIColor+ChinaMap.h
//  ChinaMap
//
//  Created by yuanyinhua on 2022/3/29.
//  Copyright © 2022 印度阿三. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ChinaMap)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)color;

@end

NS_ASSUME_NONNULL_END
