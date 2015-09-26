//
//  C4QRestaurant.h
//  TalkinToTheNet
//
//  Created by Z on 9/22/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C4QRestaurant : NSObject

@property NSString *name;
@property NSString *phoneNumber;

@property NSString *address;
@property NSString *buildingNumber;
@property NSString *street;
@property NSString *zipcode;

@property NSInteger *ratCount;
@property NSInteger *roachCount;
@property NSInteger *flyCount;

@end
