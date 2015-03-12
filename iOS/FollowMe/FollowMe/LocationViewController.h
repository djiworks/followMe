//
//  LocationViewController.h
//  FollowMe
//
//  Created by sebastien FOCK CHOW THO on 3/12/15.
//  Copyright (c) 2015 Dlg developpement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    MKMapView *map;
}

@end
