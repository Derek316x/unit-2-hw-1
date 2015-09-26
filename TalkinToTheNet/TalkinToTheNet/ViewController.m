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
#import "C4QRestaurant.h"

@interface ViewController () <
CLLocationManagerDelegate,
UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate
>

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;

@property (weak, nonatomic) IBOutlet UILabel *latLabel;
@property (weak, nonatomic) IBOutlet UILabel *longLabel;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *restaurants;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLocationManager];
    
    self.searchTextField.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
//    [self getViolationDataForNYCRestaurants];
}

#pragma mark - Location methods
-(void)setupLocationManager{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentLocation = [locations lastObject];
    self.latLabel.text =  [NSString stringWithFormat:@"%f.1f", self.currentLocation.coordinate.latitude];
     self.longLabel.text =  [NSString stringWithFormat:@"%f.1f", self.currentLocation.coordinate.longitude];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

#pragma mark - textfield delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self makeFoursquareRequestWithSearchTerm:textField.text ForLocation:self.currentLocation WithCallbackBlock:^{
        for (C4QRestaurant *restuarant in self.restaurants) {
            NSLog(@"%@",restuarant.name);
            NSLog(@"%@",restuarant.phoneNumber);
            NSLog(@"********");
        }
        [self.tableView reloadData];
    }];
    
    //dismisses the keyboard
    [self.view endEditing:YES];
    
    return YES;
}

#pragma mark - foursquare api methods

-(void)makeFoursquareRequestWithSearchTerm:(NSString *)searchTerm ForLocation:(CLLocation *)location WithCallbackBlock:(void(^)())block{
    //start updating location at beginning of method; stop updating location at end
    [self.locationManager startUpdatingLocation];
    
    NSString *latitude = [NSString stringWithFormat:@"%.1f",location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%.1f",location.coordinate.longitude];

    NSString *urlString = [NSString stringWithFormat: @"https://api.foursquare.com/v2/venues/search?client_id=RCPNIN1V5V5GCZ0F3RSFCNFIOD2K2240ZIW2ZANAOFIJWV1O&client_secret=4YZZKIM1UUUXTVG4K3RX2Y4BV3TIG2RZDIB1KUTJJJPCTK5G&v=20130815&section=food&ll=%@,%@&query=%@",latitude,longitude, searchTerm];
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:encodedString];
    
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil){
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSDictionary *venues = [[json objectForKey:@"response"] objectForKey:@"venues"];
            
            self.restaurants = [[NSMutableArray alloc] init];
            
            for (NSDictionary *venue in venues)  {
                C4QRestaurant *restaurant = [[C4QRestaurant alloc] init];
                restaurant.name = [venue objectForKey: @"name"];
                NSString *phoneNumber = [[venue objectForKey:@"contact"] objectForKey:@"phone"];
                if (phoneNumber != nil) { //only add restaurants with a phone number
                    restaurant.phoneNumber = phoneNumber;
                    [self.restaurants addObject:restaurant];
                }
            }
        }
        block();
        [self.locationManager stopUpdatingLocation];
    }];
}

#pragma mark - inspection data api methods

-(void)getViolationDataForNYCRestaurants{
    
    NSString *urlString = [NSString stringWithFormat: @"https://data.cityofnewyork.us/resource/9w7m-hzhe.json"];
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:encodedString];
    
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil){
            NSArray *jsonViolations = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *violation in jsonViolations) {
                NSString *name = [violation objectForKey:@"dba"];
                NSString *violationCode = [violation objectForKey:@"violation_code"];
                NSLog(@"%@ - %@",name,violationCode);
            }
        }
    }];
}

#pragma mark - tableView methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.restaurants.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RestaurantCellIdentifier" forIndexPath:indexPath];
    
    C4QRestaurant *restaurantForCell = self.restaurants[indexPath.row];
    
    cell.textLabel.text = restaurantForCell.name;
    
    return cell;
}

@end