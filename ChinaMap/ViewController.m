//
//  ViewController.m
//  ChinaMap
//
//  Created by 印度阿三 on 2018/10/22.
//  Copyright © 2018 印度阿三. All rights reserved.
//

#import "ViewController.h"
#import "ChinaMap.h"
#import "UIColor+ChinaMap.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    ChinaMap *map = [[ChinaMap alloc] initWithFrame:CGRectMake(10, 100, UIScreen.mainScreen.bounds.size.width - 20, 400)];
    map.backgroundColor = [UIColor colorWithHexString:@"#3b4964"];
    PGModel *model = [PGModel new];
    model.data = @{@"湖南": @"20.30", @"湖北": @"1", @"内蒙古": @"-100"};
    model.colorConfigs = @[
        @{@"value":@"0", @"color":@"#dfadde"},
        @{@"value":@"10", @"color": @"#feafff"}
    ];
    map.model = model;
    map.clickDoubleActionBlock = ^(NSString * _Nonnull province) {
        NSLog(@"double click: %@", province);
    };
    [self.view addSubview:map];
}


@end
