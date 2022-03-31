//
//  ChinaMap.h
//  ChinaMap
//
//  Created by yuanyinhua on 2022/3/30.
//  Copyright © 2022 印度阿三. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChinaMap : UIView
/**配置模型*/
@property(nonatomic,strong) PGModel *model;
/**点击地图功能 开启后关闭设置选中省份功能  默认 YES*/
@property(nonatomic,assign) BOOL clickEnable;
// 点击省份事件 只有当 clickEnable == YES 才响应
@property(nonatomic,copy) void(^clickActionBlock)(NSString *province);
// 双击事件
@property(nonatomic,copy) void(^clickDoubleActionBlock)(NSString *province);

@end
NS_ASSUME_NONNULL_END
