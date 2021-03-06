//
//  ReservePriceGroup.m
//  LXBtrip
//
//  Created by Yang Xiaozhu on 15/6/7.
//  Copyright (c) 2015年 LXB. All rights reserved.
//

#import "ReservePriceGroup.h"

@implementation ReservePriceGroup

- (id)initWithDict:(NSDictionary *)dict
{
    self.adultPrice = [dict[@"adult_price"] isKindOfClass:[NSNull class]]?nil:dict[@"adult_price"];
    self.adultNum = [dict[@"adult_person"] isKindOfClass:[NSNull class]]?nil:dict[@"adult_person"];
    
    // kid with bed
    self.kidBedPrice = [dict[@"kid_price"] isKindOfClass:[NSNull class]]?nil:dict[@"kid_price"];
    self.kidBedNum = [dict[@"kid_person"] isKindOfClass:[NSNull class]]?nil:dict[@"kid_person"];
    
    // kid no bed
    self.kidPrice = [dict[@"kid_nbed_price"] isKindOfClass:[NSNull class]]?nil:dict[@"kid_nbed_price"];
    self.kidNum = [dict[@"kid_nbed_person"] isKindOfClass:[NSNull class]]?nil:dict[@"kid_nbed_person"];

    
//    // kid with bed
//    self.kidBedPrice = [dict[@"kid_bed_price"] isKindOfClass:[NSNull class]]?nil:dict[@"kid_bed_price"];
//    self.kidBedNum = [dict[@"kid_bed_person"] isKindOfClass:[NSNull class]]?nil:dict[@"kid_bed_person"];
//
//    // kid no bed
//    self.kidPrice = [dict[@"kid_price"] isKindOfClass:[NSNull class]]?nil:dict[@"kid_bed_price"];
//    self.kidNum = [dict[@"kid_person"] isKindOfClass:[NSNull class]]?nil:dict[@"kid_bed_person"];

    self.diffPrice = [dict[@"diff_price"] isKindOfClass:[NSNull class]]?nil:dict[@"diff_price"];

    
    return self;
}


@end
