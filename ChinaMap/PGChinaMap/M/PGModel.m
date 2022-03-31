//
//  PGModel.m
//  ChinaMap
//
//  Created by 印度阿三 on 2018/10/24.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import "PGModel.h"
#import "UIColor+ChinaMap.h"

@implementation PGModel
- (UIColor *)backColorD{
    return _backColorD != nil ? _backColorD:[UIColor.whiteColor colorWithAlphaComponent:0.2];
}

- (UIColor *)backColorH{
    return _backColorH != nil ? _backColorH: [UIColor colorWithHexString:@"#6c90e5"];
}

- (UIColor *)nameColor{
    return _nameColor != nil ? _nameColor:[UIColor colorWithHexString:@"#cdcdcc"];
}

- (UIFont *)nameFont{
    return _nameFont ? _nameFont:[UIFont systemFontOfSize:12];
}

- (UIColor *)lineColor {
    return _lineColor != nil ? _lineColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8];
}


@end
