//
//  ViewController.m
//  TalkinToTheNet
//
//  Created by Michael Kavouras on 9/20/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "ViewController.h"
#import "APIManager.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLocationManager];
}

#pragma mark - Location methods
-(void)setupLocationManager{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentLocation = [locations lastObject];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

-(void)makeFoursquareRequestWithSearchTerm:(NSString *)searchTerm ForLocation:(CLLocation *)location WithCallbackBlock:(void(^)())block{
    
    NSString *latitude = [NSString stringWithFormat:@"%.1f",location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%.1f",location.coordinate.longitude];

    NSString *urlString = [NSString stringWithFormat: @"https://api.foursquare.com/v2/venues/search?client_id=RCPNIN1V5V5GCZ0F3RSFCNFIOD2K2240ZIW2ZANAOFIJWV1O&client_secret=4YZZKIM1UUUXTVG4K3RX2Y4BV3TIG2RZDIB1KUTJJJPCTK5G&v=20130815&ll=%@,%@&query=%@",latitude,longitude, searchTerm];
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:encodedString];
    
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil){
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
    }];
    
    block();
}


@end
