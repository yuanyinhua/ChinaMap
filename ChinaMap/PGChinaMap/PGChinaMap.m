//
//  PGChinaMap.m
//  ChinaMap
//
//  Created by 印度阿三 on 2018/10/24.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import "PGChinaMap.h"
#import "UIColor+ChinaMap.h"

@interface PGChinaMap ()
/**地图块贝塞尔曲线数组*/
@property(nonatomic,strong) NSMutableArray <UIBezierPath *>*pathAry;
/**地图块贝塞尔曲线数组*/
@property (nonatomic,strong) NSMutableArray <UIColor *>*colorAry;
/**各个省级行政区名字及位置数组*/
@property (nonatomic,strong) NSMutableArray <NSDictionary *>*textAry;
/**选中的地图块*/
@property (nonatomic,assign) NSUInteger seletedIdx;
/**省名对应的序号*/
@property(nonatomic,strong) NSDictionary *nameIndexDic;

/**省名序号对应的名字*/
@property(nonatomic,strong) NSDictionary *indexNameDic;
// 标注
@property (nonatomic, strong) UIView *annotationView;
// 色块
@property (nonatomic, strong) UIView *colorLumpView;

@end

@implementation PGChinaMap

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat w = frame.size.width;
        CGFloat scale = w/560;
        self.transform = CGAffineTransformMakeScale(scale, scale);//宽高伸缩比例
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, w, w * 321.43 / 375.0);
        self.clickEnable = YES;
        self.backgroundColor = [UIColor clearColor];
        self.seletedIdx = NSNotFound;
    }
    return self;
}

- (void)setModel:(PGModel *)model
{
    _model = model;
    [self setNeedsDisplay];
}

- (void)setClickEnable:(BOOL)clickEnable{
    _clickEnable = clickEnable;
    
    if (clickEnable == NO) {
        if (self.gestureRecognizers.count >0) self.gestureRecognizers = @[];
    }else{
        if (self.gestureRecognizers.count >0)return;
        
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        [self addGestureRecognizer:click];
        
        UITapGestureRecognizer *doubleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        doubleClick.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleClick];
        
        [click requireGestureRecognizerToFail:doubleClick];
    }
}

#pragma mark - Action
- (void)click:(UITapGestureRecognizer *)sender{
    NSInteger seletedIdx = [self indexWithSender:sender];
    if (seletedIdx == NSNotFound) {
        return;
    }
    _seletedIdx = seletedIdx;
    NSString *name = [self nameWithIndex:seletedIdx];
    if (self.clickActionBlock) self.clickActionBlock(name);
    [self setNeedsDisplay];
    // 标注
    self.annotationView.hidden = NO;
    CGPoint point = [sender locationInView:sender.view];
    [self.annotationView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = obj;
        if (idx == 0) {
            label.text = [NSString stringWithFormat:@"地区：%@",name];
        } else {
            label.text = [NSString stringWithFormat:@"数值：%@", self.model.data[name] ? : @"0"];
        }
    }];
    self.annotationView.center = CGPointMake(point.x, point.y - 25);
    CGSize size1 = [self.annotationView.subviews.lastObject sizeThatFits:CGSizeMake(100, 11)];
    CGSize size2 = [self.annotationView.subviews.firstObject sizeThatFits:CGSizeMake(100, 11)];
    self.annotationView.bounds = CGRectMake(0, 0, MAX(size1.width, size2.width) + 8 * 2, 46);
}

- (UIView *)annotationView
{
    if (!_annotationView) {
        _annotationView = [[UIView alloc] initWithFrame:CGRectZero];
        _annotationView.backgroundColor = [UIColor colorWithHexString:@"#333333" alpha:0.9];
        _annotationView.layer.zPosition = 10;
        _annotationView.layer.masksToBounds = YES;
        _annotationView.layer.cornerRadius = 5;
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
        label1.textColor = [UIColor whiteColor];
        label1.font = [UIFont systemFontOfSize:11];
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
        label2.textColor = [UIColor whiteColor];
        label2.font = [UIFont systemFontOfSize:11];
        [_annotationView addSubview:label1];
        [_annotationView addSubview:label2];
        
        label1.translatesAutoresizingMaskIntoConstraints = NO;
        label2.translatesAutoresizingMaskIntoConstraints = NO;
        [_annotationView.leadingAnchor constraintEqualToAnchor:label1.leadingAnchor constant:-8].active = YES;
        [_annotationView.topAnchor constraintEqualToAnchor:label1.topAnchor constant:-8].active = YES;
        [_annotationView.trailingAnchor constraintEqualToAnchor:label1.trailingAnchor constant:-8].active = YES;
        
        [label1.leadingAnchor constraintEqualToAnchor:label2.leadingAnchor].active = YES;
        [label1.rightAnchor constraintEqualToAnchor:label2.rightAnchor].active = YES;

        [label2.bottomAnchor constraintEqualToAnchor:_annotationView.bottomAnchor constant:-8].active = YES;
        [self addSubview:_annotationView];
    }
    return _annotationView;
}

- (NSString *)nameWithIndex:(NSInteger)index
{
    return self.indexNameDic[@(index + 1).stringValue];
}

- (NSInteger)indexWithSender:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    
    NSInteger seletedIdx = NSNotFound;
    for (int i = 0; i <34; i++) {
        UIBezierPath *path = self.pathAry[i];
        if (![path containsPoint:point]) {
            continue;
        }
        seletedIdx = i;
        break;
    }
    return seletedIdx;
}

- (void)doubleClick:(UITapGestureRecognizer *)sender {
    NSInteger seletedIdx = [self indexWithSender:sender];
    if (seletedIdx == NSNotFound) {
        return;
    }
    if (self.clickDoubleActionBlock) self.clickDoubleActionBlock([self nameWithIndex:seletedIdx]);
}

// 画地图
- (void)drawRect:(CGRect)rect{
    if (_model == nil) {
        return;
    }
    _colorAry = nil;
    // 根据数据获取对应的颜色值
    NSArray *colors = self.model.colorConfigs.reverseObjectEnumerator.allObjects;
    [self.model.data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        NSInteger index = [self.nameIndexDic[name] integerValue];
        NSInteger colorIndex = index - 1;
        if (value.doubleValue == 0) {
            self.colorAry[colorIndex] = self.model.backColorD;
        } else if (value.doubleValue < 0) {
            self.colorAry[colorIndex] = [UIColor colorWithHexString:@"#e6e8ea"];
        } else {
            NSDictionary *data = [colors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject[@"value"] doubleValue] <= value.doubleValue;
            }]].firstObject;
            if (colorIndex >= 0 && data && data[@"color"]) {
                self.colorAry[colorIndex] = [UIColor colorWithHexString:data[@"color"]];
            }
        }
    }];
    // 改变选中颜色的透明度
    if (_seletedIdx != NSNotFound) {
        UIColor *color = self.colorAry[_seletedIdx];
        CGFloat red = 0.0;
        CGFloat blue = 0.0;
        CGFloat green = 0.0;
        CGFloat alpha = 0.0;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        color = [UIColor colorWithRed:red green:green blue:blue alpha:MAX(0.1, alpha - 0.2)];
        self.colorAry[_seletedIdx] = color;
    }
    // 边线颜色
    UIColor *strokeColor = self.model.lineColor;
    
    [self.pathAry enumerateObjectsUsingBlock:^(UIBezierPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.miterLimit = 4;
        obj.lineJoinStyle = kCGLineJoinRound;
        [self.colorAry[idx] setFill];
        [obj fill];
        [strokeColor setStroke];
        obj.lineWidth = 1;
        [obj stroke];
    }];
    
    // 绘制文字
    __weak typeof(self) weakSelf = self;
    [self.textAry enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = obj[@"name"];
        NSValue *rectValue = obj[@"rect"];
        
        [weakSelf drawText:name color:self.model.data[name] == 0 ? [UIColor colorWithHexString:@"#cdcdcc"] : [UIColor whiteColor] rect:rectValue];
    }];
}


- (void)drawText:(NSString *)name color:(UIColor *)color rect:(NSValue *)rect
{
    CGRect textRect = [rect CGRectValue];
    {
        NSString *textContent = name;
        CGContextRef context = UIGraphicsGetCurrentContext();
        NSMutableParagraphStyle *textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        textStyle.alignment = NSTextAlignmentLeft;
        // 省份名字: 字号 颜色 段落样式
        NSDictionary *dic = @{
            NSFontAttributeName: self.model.nameFont
            , NSForegroundColorAttributeName: color ? : self.model.nameColor, NSParagraphStyleAttributeName: textStyle
        };
        
        CGFloat textH = [textContent boundingRectWithSize: CGSizeMake(textRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: dic context: nil].size.height;
        
        CGContextSaveGState(context);
        CGContextClipToRect(context, textRect);
        [textContent drawInRect: CGRectMake(CGRectGetMinX(textRect), CGRectGetMinY(textRect) + (CGRectGetHeight(textRect) - textH) / 2, CGRectGetWidth(textRect), textH) withAttributes: dic];
        CGContextRestoreGState(context);
    }
}

#pragma mark - 懒加载
-(NSMutableArray<UIBezierPath *> *)pathAry{
    if (_pathAry == nil) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"ChinaMapPaths" ofType:@"plist"];
        NSData *pathsData = [NSData dataWithContentsOfFile:sourcePath];
        _pathAry = [NSKeyedUnarchiver unarchiveObjectWithData:pathsData];
        
    }
    return _pathAry;
}


- (NSMutableArray *)colorAry{
    if (_colorAry == nil) {
        _colorAry = [NSMutableArray arrayWithCapacity:34];
        for (int i = 0; i <34; i++) {
            UIColor* fillColor = self.model.backColorD;
            [_colorAry addObject:fillColor];
        }
    }
    return _colorAry;
}

- (NSMutableArray *)textAry{
    if (_textAry != nil) {
        return _textAry;
    }
    
    return [self readFromDisk];
    
    
}

// plist文件读取省份名字
- (NSMutableArray *)readFromDisk{
    
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"ProvincialName" ofType:@"plist"];
    NSData *data = [NSData dataWithContentsOfFile:sourcePath];
    NSMutableArray *nameAry = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return nameAry;
    
}

// 序号从1开始 避免无内容key查到0
- (NSDictionary *)nameIndexDic{
    
    if (!_nameIndexDic) {
        _nameIndexDic = @{
            @"黑龙江" : @"1",
            @"吉林" : @"2",
            @"辽宁" : @"3",
            @"河北" : @"4",
            @"山东" : @"5",
            @"新疆" : @"29",
            @"青海" : @"20",
            @"西藏" : @"30",
            @"四川" : @"18",
            @"云南" : @"19",
            @"广西" : @"28",
            @"甘肃" : @"12",
            @"宁夏" : @"26",
            @"重庆" : @"23",
            @"海南" : @"21",
            @"广东" : @"31",
            @"澳门" : @"34",
            @"香港" : @"32",
            @"台湾" : @"33",
            @"福建" : @"15",
            @"湖南" : @"16",
            @"江西" : @"14",
            @"浙江" : @"7",
            @"上海" : @"22",
            @"湖北" : @"13",
            @"河南" : @"9",
            @"山西" : @"10",
            @"陕西" : @"11",
            @"北京" : @"24",
            @"天津" : @"25",
            @"内蒙古" : @"27",
            @"安徽" : @"8",
            @"江苏" : @"6",
            @"贵州" : @"17"
        };
    }
    return _nameIndexDic;
}

- (NSDictionary *)indexNameDic{
    
    if (!_indexNameDic) {
        _indexNameDic = @{
            @"1": @"黑龙江",
            @"2" : @"吉林",
            @"3" : @"辽宁",
            @"4" : @"河北",
            @"5" : @"山东",
            @"29" : @"新疆",
            @"20" : @"青海",
            @"30" : @"西藏",
            @"18" : @"四川",
            @"19" : @"云南",
            @"28" : @"广西",
            @"12" : @"甘肃",
            @"26" : @"宁夏",
            @"23" : @"重庆",
            @"21" : @"海南",
            @"31" : @"广东",
            @"34" : @"澳门",
            @"32" : @"香港",
            @"33" : @"台湾",
            @"15" : @"福建",
            @"16" : @"湖南",
            @"14" : @"江西",
            @"7" : @"浙江",
            @"22" : @"上海",
            @"13" : @"湖北",
            @"9" : @"河南",
            @"10" : @"山西",
            @"11" : @"陕西",
            @"24" : @"北京",
            @"25" : @"天津",
            @"27" : @"内蒙古",
            @"8" : @"安徽",
            @"6" : @"江苏",
            @"17" : @"贵州"
        };
    }
    return _indexNameDic;
}

@end
