//
//  ChinaMap.m
//  ChinaMap
//
//  Created by yuanyinhua on 2022/3/30.
//  Copyright © 2022 印度阿三. All rights reserved.
//

#import "ChinaMap.h"
#import "PGChinaMap.h"
#import "UIColor+ChinaMap.h"

@interface ChinaMap ()
// 地图
@property (nonatomic, strong) PGChinaMap *map;
// 颜色块
@property (nonatomic, strong) UIView *colorsView;

@end

@implementation ChinaMap

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        PGChinaMap *map = [[PGChinaMap alloc] initWithFrame:CGRectMake(10, 20, frame.size.width - 20, frame.size.height)];
        [self addSubview:map];
        _map = map;
    }
    return self;
}

- (void)setModel:(PGModel *)model
{
    self.map.model = model;
    if (model.colorConfigs.count > 0) {
        _colorsView = [self viewWithModel:model];
        CGRect frame = self.frame;
        frame.size.height = CGRectGetMaxY(_colorsView.frame);
        self.frame = frame;
        [self addSubview:_colorsView];
    } else {
        _colorsView.hidden = YES;
        [_colorsView removeFromSuperview];
    }
}

// 整个色块区域
- (UIView *)viewWithModel:(PGModel *)model
{
    NSMutableArray *configs = [NSMutableArray arrayWithCapacity:model.colorConfigs.count];
    [configs addObject:@{@"value":@"0", @"color": [UIColor.whiteColor colorWithAlphaComponent:0.2]}];
    if ([model.data.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject doubleValue] < 0;
    }]].count > 0) {
        [configs addObject:@{@"value":@"<0", @"color": [UIColor colorWithHexString:@"#e6e8ea"]}];
    }
    
    [model.colorConfigs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        double value = [obj[@"value"] doubleValue];
        [configs addObject:@{@"value": value == 0 ? @">0" : [NSString stringWithFormat:@">=%@", obj[@"value"]] , @"color": [UIColor colorWithHexString:obj[@"color"]]}];
    }];
    
    NSInteger count = configs.count;
    NSInteger itemCount = 4;
    NSInteger line = (count / itemCount) + 1 + count % itemCount > 0 ? 1 : 0;
    CGFloat space = 15;
    CGFloat size = 12;
    CGFloat viewLeft = 64;
    CGFloat viewWidth = self.frame.size.width - viewLeft - 30;
    CGFloat width = viewWidth / itemCount;
    UIView *colorsView = [[UIView alloc] initWithFrame:CGRectMake(viewLeft, CGRectGetMaxY(self.map.frame) + 30, viewWidth, line * size + (line - 1) * space + 20)];
    for (int i = 0; i < count; i++) {
        NSInteger line = (i / itemCount);
        NSInteger column = i % itemCount;
        NSDictionary *data = configs[i];
        UIView *item = [self itemViewWithName:data[@"value"] color:data[@"color"]];
        item.frame = CGRectMake(column * width, line * size, width, size);
        [colorsView addSubview:item];
    }
    return colorsView;
}

// 单个色块和文字
- (UIView *)itemViewWithName:(NSString *)name color:(UIColor *)color
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = name;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:8];
    colorView.backgroundColor = color;
    colorView.layer.masksToBounds = YES;
    colorView.layer.cornerRadius = 3;
    [view addSubview:label];
    [view addSubview:colorView];
    
    colorView.translatesAutoresizingMaskIntoConstraints = NO;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [colorView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:0].active = YES;
    [colorView.topAnchor constraintEqualToAnchor:view.topAnchor constant:0].active = YES;
    [colorView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:0].active = YES;
    [colorView.widthAnchor constraintEqualToAnchor:view.heightAnchor].active = YES;
    
    [label.leadingAnchor constraintEqualToAnchor:colorView.trailingAnchor constant:5].active = YES;
    [label.topAnchor constraintEqualToAnchor:view.topAnchor constant:0].active = YES;
    [label.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = YES;
    [label.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-5].active = YES;
    return view;
}

- (void)setClickEnable:(BOOL)clickEnable
{
    self.map.clickEnable = clickEnable;
}

- (void)setClickActionBlock:(void (^)(NSString * _Nonnull))clickActionBlock
{
    self.map.clickActionBlock = clickActionBlock;
}

- (void)setClickDoubleActionBlock:(void (^)(NSString * _Nonnull))clickDoubleActionBlock
{
    self.map.clickDoubleActionBlock = clickDoubleActionBlock;
}

@end

