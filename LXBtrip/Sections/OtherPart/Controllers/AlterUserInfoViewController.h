//
//  AlterUserInfoViewController.h
//  LXBtrip
//
//  Created by Sam on 6/10/15.
//  Copyright (c) 2015 LXB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavBaseViewController.h"


@protocol UpdateUserInformationDelegate <NSObject>

- (void)updateUserInformationSuccessfully;

@end


typedef enum : NSUInteger {
    ShopContactName,
    ShopName,
    DetailAdress,
} AlterInfoTypes;

@interface AlterUserInfoViewController : NavBaseViewController

@property (assign, nonatomic) AlterInfoTypes type;

@property (retain, nonatomic) NSDictionary *userInfoDic;

@property (weak, nonatomic) id<UpdateUserInformationDelegate> delegate;

@end
