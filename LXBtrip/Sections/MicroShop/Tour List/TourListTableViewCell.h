//
//  TourListTableViewCell.h
//  LXBtrip
//
//  Created by Yang Xiaozhu on 15/5/28.
//  Copyright (c) 2015年 LXB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppMacro.h"

@protocol TourListTableViewCell_Delegate <NSObject>

- (void)supportClickWithShareButtonWithProduct:(SupplierProduct *)product;
- (void)supportClickWithPreviewButtonWithProduct:(SupplierProduct *)product;
- (void)supportClickWithAccompanyInfoWithProduct:(SupplierProduct *)product;

@end

@interface TourListTableViewCell : UITableViewCell

@property (nonatomic, weak) id<TourListTableViewCell_Delegate>delegate;

- (void)setCellContentWithSupplierProduct:(SupplierProduct *)product;
@end
