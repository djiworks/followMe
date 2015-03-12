//
//  LocationViewController.m
//  FollowMe
//
//  Created by sebastien FOCK CHOW THO on 3/12/15.
//  Copyright (c) 2015 Dlg developpement. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController () {
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self makeTheView];
    [self initLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)makeTheView {
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - actions

- (void)initLocation {
    geocoder = [[CLGeocoder alloc] init];
    
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        
        if ([locationManager respondsToSelector:
             @selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        
        if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.delegate = self;
    }
    
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManager methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil&& [placemarks count] >0) {
            placemark = [placemarks lastObject];
            
            NSString *latitude, *longitude, *state, *country;
            
            latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
            longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
            state = placemark.administrativeArea;
            country = placemark.country;
            
            NSLog(@"%@, %@", latitude, longitude);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
    
    // Turn off the location manager to save power.
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Cannot find the location.");
}

@end
