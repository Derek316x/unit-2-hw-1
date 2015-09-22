//
//  ViewController.m
//  TalkinToTheNet
//
//  Created by Michael Kavouras on 9/20/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "ViewController.h"
#import "FourSquareKit.h"
#import "MKNetworkKit.h"


@interface ViewController ()
@property (nonatomic) UXRFourSquareNetworkingEngine *fourSquareEngine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNetworkingEngine];
    [self getNearbyTacoRestaurants];
}

-(void)registerNetworkingEngine{
    NSString *yourClientId = @"RCPNIN1V5V5GCZ0F3RSFCNFIOD2K2240ZIW2ZANAOFIJWV1O";
    NSString *yourClientSecret = @"4YZZKIM1UUUXTVG4K3RX2Y4BV3TIG2RZDIB1KUTJJJPCTK5G";
    NSString *yourCallbackURl = @"http://google.com";
    [UXRFourSquareNetworkingEngine registerFourSquareEngineWithClientId:yourClientId andSecret:yourClientSecret andCallBackURL:yourCallbackURl];
    self.fourSquareEngine = [UXRFourSquareNetworkingEngine sharedInstance];
}

-(void)getNearbyTacoRestaurants{
    NSString *locationString = @"Seattle";
    NSString *query = @"tacos";
    [self.fourSquareEngine exploreRestaurantsNearLocation:locationString
                                                withQuery:query
                                      withCompletionBlock:^(NSArray *restaurants) {
                                          UXRFourSquareRestaurantModel *restaurantModel = (UXRFourSquareRestaurantModel *)restaurants[0];
                                          NSLog(@"%@",restaurantModel);
                                      } failureBlock:^(NSError *error) {
                                          // Error
                                      }];
}

@end
