//
//  GuestMapViewController.m
//  GuestVite
//
//  Created by admin on 2016-11-05.
//  Copyright © 2016 admin. All rights reserved.
//

#import "GuestMapViewController.h"
#import "MapKit/MapKit.h"
@import GoogleMaps;


@interface GuestMapViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property(strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation GuestMapViewController

BOOL didFindMyLocation = FALSE;

CLLocation  *myLocation;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.8683
                                                            //longitude:151.2086
                                                                // zoom:10.0];
    //self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.indoorEnabled = NO;
    self.mapView.accessibilityElementsHidden = NO;
    self.mapView.settings.myLocationButton = YES;
    
    //1. Get guest's current location
    
    
    //[self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
        
    });
    
    while(!didFindMyLocation) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    [self drawPathFrom];
    
}


- (void)dealloc {
    [self.mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if(!didFindMyLocation) {
        
        myLocation = [change objectForKey:NSKeyValueChangeNewKey];
        
        
        [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:myLocation.coordinate.latitude longitude:myLocation.coordinate.longitude zoom:10.0]];
        //self.mapView.settings.myLocationButton = YES;
        NSLog(@"YOUR LOCATION LATITUDE %f",myLocation.coordinate.latitude);
        NSLog(@"YOUR LOCATION LONGITUDE %f",myLocation.coordinate.longitude);
        
               didFindMyLocation = TRUE;
        
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)drawPathFromAlt {
    
    
    
    
    
    NSString *baseUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=%f,%f&destinations=%@&key=AIzaSyB7VO2twlrdlQZU-zlz5XDSSbtrFrCDkek", myLocation.coordinate.latitude, myLocation.coordinate.longitude,_hostAddr];
    
    
    NSURL *url = [NSURL URLWithString:[baseUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    NSLog(@"Url: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError){
            NSDictionary *result        = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *routes             = [result objectForKey:@"routes"];
            NSDictionary *firstRoute    = [routes objectAtIndex:0];
            NSString *encodedPath       = [firstRoute[@"overview_polyline"] objectForKey:@"points"];
            
            GMSPolyline *polyPath       = [GMSPolyline polylineWithPath:[GMSPath pathFromEncodedPath:encodedPath]];
            polyPath.strokeColor        = [UIColor blueColor];
            polyPath.strokeWidth        = 5.5f;
            polyPath.map                = self.mapView;
        }
    }];
    
}

- (void)drawPathFrom {
    
    
    NSString *baseUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%@&sensor=true&key=AIzaSyB7VO2twlrdlQZU-zlz5XDSSbtrFrCDkek", myLocation.coordinate.latitude, myLocation.coordinate.longitude,_hostAddr];

    
    NSURL *url = [NSURL URLWithString:[baseUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    NSLog(@"Url: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError){
            NSDictionary *result        = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *routes             = [result objectForKey:@"routes"];
            NSDictionary *firstRoute    = [routes objectAtIndex:0];
            NSString *encodedPath       = [firstRoute[@"overview_polyline"] objectForKey:@"points"];
            
            GMSPolyline *polyPath       = [GMSPolyline polylineWithPath:[GMSPath pathFromEncodedPath:encodedPath]];
            polyPath.strokeColor        = [UIColor blueColor];
            polyPath.strokeWidth        = 5.5f;
            polyPath.map                = self.mapView;
            [self.mapView addSubview:polyPath.map];
        }
    }];
    
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
