//
//  MySupplierViewController.m
//  LXBtrip
//
//  Created by Yang Xiaozhu on 15/6/3.
//  Copyright (c) 2015年 LXB. All rights reserved.
//

#import "MySupplierViewController.h"
#import "MySupplierTableViewCell.h"
#import "SupplierDetailViewController.h"

@interface MySupplierViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSInteger selectedIndex; // 0~4
    NSMutableArray *tableViewsArray;
    NSMutableArray *noSuppliersArray;
    BOOL listNeedsRefreshing;
}

//专线part
@property (strong, nonatomic) IBOutlet UIButton *zhuanXianButton;
@property (strong, nonatomic) IBOutlet UIButton *domesticButton_zhuanXian;
- (IBAction)domesticButton_zhuanXianClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *abroadButton_zhuanXian;
- (IBAction)abroadButton_zhuanXianClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *nearbyButton_zhuanXian;
- (IBAction)nearbyButton_zhuanXianClicked:(id)sender;

// 地接part
@property (strong, nonatomic) IBOutlet UIButton *diJieButton;
@property (strong, nonatomic) IBOutlet UIButton *domesticButton_diJie;
- (IBAction)domesticButton_diJieClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *abroadBUtton_diJie;
- (IBAction)abroadBUtton_diJieClicked:(id)sender;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *underLineLabel;

@property (nonatomic, copy) NSMutableArray *allSectionsArray;
@property (nonatomic, copy) NSMutableArray *allMySuppliersArray;

@end

@implementation MySupplierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mySupplierListHasChanged) name:MY_SHOP_HAS_UPDATED object:nil];
    
    _allSectionsArray = [[NSMutableArray alloc] initWithObjects:[@[] mutableCopy], [@[] mutableCopy], [@[] mutableCopy], [@[] mutableCopy], [@[] mutableCopy], nil];
    _allMySuppliersArray = [[NSMutableArray alloc] initWithObjects:[@[] mutableCopy], [@[] mutableCopy], [@[] mutableCopy], [@[] mutableCopy], [@[] mutableCopy], nil];
    
    CGFloat yOrigin = 82.f;
    _underLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yOrigin-2, (SCREEN_WIDTH/2.f)/3, 2)];
    _underLineLabel.backgroundColor = TEXT_4CA5FF;
    [self.view addSubview:_underLineLabel];
    // initial status
    [_zhuanXianButton setSelected:YES];
    [_diJieButton setSelected:NO];

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, yOrigin, SCREEN_WIDTH, SCREEN_HEIGHT - yOrigin - 64.f)];
    [_scrollView setContentSize:CGSizeMake(5*SCREEN_WIDTH, _scrollView.frame.size.height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollEnabled = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    tableViewsArray = [[NSMutableArray alloc] initWithCapacity:5];
    noSuppliersArray = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectOffset(_scrollView.bounds, i*SCREEN_WIDTH, 0)];
        [tableview registerNib:[UINib nibWithNibName:@"MySupplierTableViewCell" bundle:nil] forCellReuseIdentifier:@"MySupplierTableViewCell"];
        tableview.dataSource = self;
        tableview.delegate = self;
        tableview.tableFooterView = [[UIView alloc] init];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectOffset(_scrollView.bounds, i*SCREEN_WIDTH, 0)];
        bgView.backgroundColor = BG_E9ECF5;
        CGFloat width_height_ratio = 656.f/536.f;
        CGFloat imgHeight = 0.4*bgView.bounds.size.height;
        CGFloat imgWidth = imgHeight*width_height_ratio;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((bgView.bounds.size.width - imgWidth)/2.0, 0.1*bgView.bounds.size.height, imgWidth, imgHeight)];
        imgView.backgroundColor = [UIColor clearColor];
        imgView.image = ImageNamed(@"no_my_supplier");
        [bgView addSubview:imgView];
        // no supplier view initially hidden!
        bgView.hidden = YES;
        
        [_scrollView addSubview:tableview];
        [_scrollView addSubview:bgView];
        
        [tableViewsArray addObject:tableview];
        [noSuppliersArray addObject:bgView];
    }
    
    selectedIndex = 0;
    listNeedsRefreshing = NO;
    [self getMySuppliers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"我的供应商";
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    if ([[Global sharedGlobal] networkAvailability] == NO) {
        [self networkUnavailable];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)mySupplierListHasChanged
{
    listNeedsRefreshing = YES;
    [self getMySuppliers];
}

#pragma mark - Override
- (void)networkUnavailable
{
    CGFloat yOrigin = 82.f + 64.f;
    [[NoNetworkView sharedNoNetworkView] showWithYOrigin:yOrigin height:SCREEN_HEIGHT - yOrigin];
}

- (void)networkAvailable
{
    [super networkAvailable];
}

- (void)getMySuppliers
{
    [HTTPTool getMySuppliersWithCompanyId:[UserModel companyId] staffId:[UserModel staffId] lineClass:LINE_CLASS[@(selectedIndex)] success:^(id result) {
        
        [noSuppliersArray[selectedIndex] setHidden:YES];
        if (listNeedsRefreshing == YES) {
            [_allMySuppliersArray[selectedIndex] removeAllObjects];
            listNeedsRefreshing = NO;
        }
        
        [[Global sharedGlobal] codeHudWithObject:result[@"RS100018"] succeed:^{
            id data = result[@"RS100018"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                
                NSMutableArray *tempUngrouped = [[NSMutableArray alloc] init];
                //my_supplier part
                id mySuppliersData = data[@"my_supplier"];
                if ([mySuppliersData isKindOfClass:[NSArray class]]) {
                    [mySuppliersData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        SupplierInfo *info= [[SupplierInfo alloc] initWithDict:obj];
                        // 需要手动指定，返回参数中没有，“我的供应商”自然肯定是“我的”
                        info.supplierIsMy = @"0";
                        [tempUngrouped addObject:info];
                    }];
                    // 重新根据字母排序
                    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"supplierLineTypeLetter" ascending:YES];
                    tempUngrouped = [[tempUngrouped sortedArrayUsingDescriptors:@[descriptor]] mutableCopy];
                    
                    [tempUngrouped enumerateObjectsUsingBlock:^(SupplierInfo *info, NSUInteger idx, BOOL *stop) {
                        __block BOOL inOldSection = NO;
                        [_allSectionsArray[selectedIndex] enumerateObjectsUsingBlock:^(NSString *initial, NSUInteger idx, BOOL *stop) {
                            if ([initial isEqualToString:info.supplierLineTypeLetter]) {
                                inOldSection = YES;
                            }
                        }];
                        if (inOldSection == NO) {
                            [_allSectionsArray[selectedIndex] addObject:info.supplierLineTypeLetter];
                        }
                    }];
                    
                    [_allSectionsArray[selectedIndex] enumerateObjectsUsingBlock:^(NSString *initial, NSUInteger idx, BOOL *stop) {
                        NSMutableArray *tempUnit = [[NSMutableArray alloc] init];
                        [tempUngrouped enumerateObjectsUsingBlock:^(SupplierInfo *info, NSUInteger idx, BOOL *stop) {
                            if ([initial isEqualToString:info.supplierLineTypeLetter]) {
                                [tempUnit addObject:info];
                            }
                        }];
                        NSDictionary *tempUnitDict = @{initial:tempUnit};
                        [_allMySuppliersArray[selectedIndex] addObject:tempUnitDict];
                    }];
                
                } else {
                    [noSuppliersArray[selectedIndex] setHidden:NO];
                    return ;
                }
            }
            [tableViewsArray[selectedIndex] reloadData];
        }];
    } fail:^(id result) {
        
        if ([[Global sharedGlobal] networkAvailability] == NO) {
            [self networkUnavailable];
            return ;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取我的供应商失败" message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_allSectionsArray[selectedIndex] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_allMySuppliersArray[selectedIndex] count] > section) {
        return [[_allMySuppliersArray[selectedIndex][section] objectForKey:_allSectionsArray[selectedIndex][section]] count];
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MySupplierTableViewCell *cell = (MySupplierTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MySupplierTableViewCell" forIndexPath:indexPath];
    NSArray *subArray = [_allMySuppliersArray[selectedIndex][indexPath.section] objectForKey:_allSectionsArray[selectedIndex][indexPath.section]];
    [cell setCellContentWithSupplierInfo:subArray[indexPath.row]];
    return cell;
}

// 索引目录
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _allSectionsArray[selectedIndex];
}

// 点击目录
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SupplierDetailViewController *detail = [[SupplierDetailViewController alloc] init];
    NSArray *subArray = [_allMySuppliersArray[selectedIndex][indexPath.section] objectForKey:_allSectionsArray[selectedIndex][indexPath.section]];
    SupplierInfo *curInfo = subArray[indexPath.row];
    detail.info = curInfo;
    [self.navigationController pushViewController:detail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = TEXT_666666;
    label.backgroundColor = BG_F5F5F5;
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = _allSectionsArray[selectedIndex][section];
    
    return label;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.f;
}

- (IBAction)domesticButton_zhuanXianClicked:(id)sender {
    selectedIndex = 0;
    if (selectedIndex <= 2) {
        [_zhuanXianButton setSelected:YES];
        [_diJieButton setSelected:NO];
    } else {
        [_zhuanXianButton setSelected:NO];
        [_diJieButton setSelected:YES];
    }
    [self scrollToVisibleWithSelectedIndex:selectedIndex];
}
- (IBAction)abroadButton_zhuanXianClicked:(id)sender {
    selectedIndex = 1;
    if (selectedIndex <= 2) {
        [_zhuanXianButton setSelected:YES];
        [_diJieButton setSelected:NO];
    } else {
        [_zhuanXianButton setSelected:NO];
        [_diJieButton setSelected:YES];
    }
    [self scrollToVisibleWithSelectedIndex:selectedIndex];
}
- (IBAction)nearbyButton_zhuanXianClicked:(id)sender {
    selectedIndex = 2;
    if (selectedIndex <= 2) {
        [_zhuanXianButton setSelected:YES];
        [_diJieButton setSelected:NO];
    } else {
        [_zhuanXianButton setSelected:NO];
        [_diJieButton setSelected:YES];
    }
    [self scrollToVisibleWithSelectedIndex:selectedIndex];
}
- (IBAction)domesticButton_diJieClicked:(id)sender {
    selectedIndex = 3;
    if (selectedIndex <= 2) {
        [_zhuanXianButton setSelected:YES];
        [_diJieButton setSelected:NO];
    } else {
        [_zhuanXianButton setSelected:NO];
        [_diJieButton setSelected:YES];
    }
    [self scrollToVisibleWithSelectedIndex:selectedIndex];
}
- (IBAction)abroadBUtton_diJieClicked:(id)sender {
    selectedIndex = 4;
    if (selectedIndex <= 2) {
        [_zhuanXianButton setSelected:YES];
        [_diJieButton setSelected:NO];
    } else {
        [_zhuanXianButton setSelected:NO];
        [_diJieButton setSelected:YES];
    }
    [self scrollToVisibleWithSelectedIndex:selectedIndex];
}

- (void)scrollToVisibleWithSelectedIndex:(NSInteger)index
{
    [UIView animateWithDuration:0.2 animations:^{
        [_scrollView scrollRectToVisible:CGRectOffset(_scrollView.frame, index*SCREEN_WIDTH, 0) animated:NO];
        if (index < 3) {
            [_underLineLabel setFrame:CGRectMake(index*(SCREEN_WIDTH/2.0)/3, _underLineLabel.frame.origin.y, (SCREEN_WIDTH/2.0)/3, _underLineLabel.frame.size.height)];
        } else {
            [_underLineLabel setFrame:CGRectMake(SCREEN_WIDTH/2.0 + (index-3)*(SCREEN_WIDTH/2.0)/2, _underLineLabel.frame.origin.y, (SCREEN_WIDTH/2.0)/2, _underLineLabel.frame.size.height)];
        }
    }];
    if ([_allMySuppliersArray[index] count] == 0) {
        [self getMySuppliers];
    }
}

@end
