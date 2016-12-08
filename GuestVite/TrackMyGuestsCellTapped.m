//
//  TrackMyGuestsCellTapped.m
//  GuestVite
//
//  Created by admin on 2016-11-06.
//  Copyright © 2016 admin. All rights reserved.
//

#import "TrackMyGuestsCellTapped.h"
#import "HomePageViewController.h"
#import "TrackMyGuestsViewController.h"
#import "MapKit/MapKit.h"
#import "CNPPopupController.h"
#import <MessageUI/MessageUI.h>

@import Firebase;

@interface TrackMyGuestsCellTapped () <MKMapViewDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong,nonatomic) MKPointAnnotation *guestLocationAnno;

@property (strong,nonatomic) MKPointAnnotation *yourLocationAnno;


@property (weak, nonatomic) IBOutlet UINavigationBar *myGuestsLocationBack;

@property(nonatomic,assign) BOOL mapIsMoving;
@property (weak, nonatomic) IBOutlet UILabel *etaTimeLabel;


@property (weak, nonatomic) IBOutlet UILabel *mileLabel;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation TrackMyGuestsCellTapped

NSMutableString *hostLatitude;
NSMutableString *hostLongitude;

NSMutableString *guestLatitude;
NSMutableString *guestLongitude;
NSMutableString *guestStatus;

NSMutableString *guestFirstName;

NSMutableString *hostFirstName;
NSMutableString *hostLastName;

NSTimer *newTimer;
float totalDistance;

-(void) viewDidAppear:(BOOL)animated{
    
    
    //NSLog(@"View DID APPEAR");
    if ([guestStatus isEqualToString:@"REACHED"]) {
        
        
        //NSLog(@"SHOW THIS!!");
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Guest Reached or is very close to your place, Enjoy your time!"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }
    
    
    else if ([guestStatus isEqualToString:@"NOT_PERMITTED"]) {
        
        
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Looks Like the Guest has not given their permission to show their location, Sorry About that!"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }

    
    
    
    else if([guestStatus isEqualToString:@"NOT_STARTED"]){
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Guest Not started yet, Please check later"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];

        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }

    
    // IF GUEST IN TRANSIT
    
    else if([guestStatus isEqualToString:@"IN_TRANSIT"]){
        
        self.mapIsMoving  = NO;
        self.mapView.camera.altitude *= 1.4;
        
        [self.view addSubview:self.indicator];
        [self.indicator startAnimating];
        
        [self.indicator.layer setBackgroundColor:[[UIColor colorWithWhite: 0.0 alpha:0.30] CGColor]];
        CGPoint center = self.view.center;
        self.indicator.center = center;

        
    newTimer =  [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refreshLocation) userInfo:nil repeats:YES];
        
            }

    
    
    
 
    [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width,80.0)];
}



// Test - Find ETA method


-(void) findETA:(CLLocationDegrees)hostLati withHostLongitude:(CLLocationDegrees)hostLongi withGuestLatitude:(CLLocationDegrees)guestLati withGuestLongitude:(CLLocationDegrees)guestLongi{
    
    
    NSLog(@"Parameters Received In ETA - Host Latitude %f",hostLati);
    NSLog(@"Parameters Received In ETA - Host Longitude %f",hostLongi);
    NSLog(@"Parameters Received In ETA - Guest Latitude %f",guestLati);
    NSLog(@"Parameters Received In ETA - Guest Latitude %f",guestLongi);
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *guestPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(guestLati,guestLongi) addressDictionary:nil];
    
    [request setSource:[[MKMapItem alloc] initWithPlacemark:guestPlacemark]];
    
    
    MKPlacemark *hostPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(hostLati,hostLongi) addressDictionary:nil];
    
    [request setDestination:[[MKMapItem alloc] initWithPlacemark:hostPlacemark]];
    
    
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    [request setRequestsAlternateRoutes:NO];
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if ( ! error && [response routes] > 0) {
            MKRoute *route = [[response routes] objectAtIndex:0];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm a"];
            NSDateComponents *components= [[NSDateComponents alloc] init];
            [components setMinute:route.expectedTravelTime/60];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *myNewDate=[calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
            
            self.etaTimeLabel.text = [formatter stringFromDate:myNewDate];
            
            NSLog(@"ETA TIME LABEL IS %@",self.etaTimeLabel.text);
        }
    }];

}

// Test Find ETA ends

-(void)refreshLocation {
    

    guestLatitude = [[NSMutableString alloc]init];
    guestLongitude = [[NSMutableString alloc]init];
    guestStatus = [[NSMutableString alloc]init];
    
    __block NSMutableString *myHostLatitude = [[NSMutableString alloc]init];
    
    __block NSMutableString *myHostLongitude = [[NSMutableString alloc]init];
    
    __block NSMutableString *myGuestLatitude = [[NSMutableString alloc]init];;
    
    __block NSMutableString *myGuestLongitude = [[NSMutableString alloc]init];
    
    __block NSMutableString *myGuestStatus = [[NSMutableString alloc]init];
    
    
    
    
    self.ref = [[FIRDatabase database] reference];
    
   
    
    [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        //NSLog(@"DICT %@",dict);
        
        myHostLatitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Host Latitude"]];
        myHostLongitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Host Longitude"]];
        myGuestLatitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Guest Latitude"]];
        myGuestLongitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Guest Longitude"]];
        myGuestStatus = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Guest Location Status"]];
        
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    
    while([myHostLatitude floatValue] == 0.0 && [myHostLongitude floatValue] == 0.0 && [myGuestLatitude floatValue] == 0.0 && [myGuestLongitude floatValue] == 0.0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    hostLatitude = myHostLatitude;
    hostLongitude = myHostLongitude;
    guestLatitude = myGuestLatitude;
    guestLongitude = myGuestLongitude;
    guestStatus = myGuestStatus;
    
   
    [self addAnnotations];
    
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    self.indicator.hidden = TRUE;
    //Test Calling find ETA method
    
    [self findETA:[hostLatitude floatValue] withHostLongitude: [hostLongitude floatValue] withGuestLatitude: [guestLatitude floatValue] withGuestLongitude:[guestLongitude floatValue]];
    
   
    //NSLog(@"Guest Status inside refresh Location is %@",guestStatus);
    
    
    //Find Distance Remaining
    float distRemainingMile = [[[CLLocation alloc] initWithLatitude:[hostLatitude floatValue] longitude:[hostLongitude floatValue]] distanceFromLocation:[[CLLocation alloc] initWithLatitude:[guestLatitude floatValue] longitude:[guestLongitude floatValue]]] * 0.000621371;
    
    
    float distRemainingKM = [[[CLLocation alloc] initWithLatitude:[hostLatitude floatValue] longitude:[hostLongitude floatValue]] distanceFromLocation:[[CLLocation alloc] initWithLatitude:[guestLatitude floatValue] longitude:[guestLongitude floatValue]]]/1000;
    
    
    NSLog(@"Distance Remaining IM MILES %.02f",distRemainingMile);
    self.mileLabel.text = [NSString stringWithFormat:@"%.02f Mi ,(%.02f Km)",distRemainingMile,distRemainingKM];
    
    
   // NSLog(@"Distance Remaining IM KM %.02f",distRemainingKM);
   // self.kmLabel.text = [NSString stringWithFormat:@"%.02f",distRemainingKM];
    
    
    // If Guest nearing - Remaining Distance < 10% of Total Distance
    
    if([[[CLLocation alloc] initWithLatitude:[hostLatitude floatValue] longitude:[hostLongitude floatValue]] distanceFromLocation:[[CLLocation alloc] initWithLatitude:[guestLatitude floatValue] longitude:[guestLongitude floatValue]]] < 0.1 * totalDistance){
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Your Guest is nearing your place, Enjoy your time!"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }
    
    
    
    // If Guest reached Destination
    
    if([guestStatus isEqualToString:@"REACHED"]){
        
        //NSLog(@"Going inside here");
        //return;
        [newTimer invalidate];
        newTimer = nil;
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Guest Reached or is very close to your place, Enjoy your time!"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    }




-(void) findTotalDist {
    
    
    
    guestFirstName = [[NSMutableString alloc]init];
    hostFirstName =  [[NSMutableString alloc]init];
    hostLastName = [[NSMutableString alloc]init];
    hostLatitude = [[NSMutableString alloc]init];
    hostLongitude = [[NSMutableString alloc]init];
    guestLatitude = [[NSMutableString alloc]init];
    guestLongitude = [[NSMutableString alloc]init];
    guestStatus = [[NSMutableString alloc]init];
    
    
    __block NSMutableString *myHostLatitude = [[NSMutableString alloc]init];
    
    __block NSMutableString *myHostLongitude = [[NSMutableString alloc]init];
    
    __block NSMutableString *myGuestLatitude = [[NSMutableString alloc]init];;
    
    __block NSMutableString *myGuestLongitude = [[NSMutableString alloc]init];
    
    __block NSMutableString *myGuestStatus = [[NSMutableString alloc]init];
    
    __block NSMutableString *myGuestFirstName = [[NSMutableString alloc]init];
    
    __block NSMutableString *myHostFirstName = [[NSMutableString alloc]init];
    
    __block NSMutableString *myHostLastName = [[NSMutableString alloc]init];
    
    //NSLog(@"KEY %@",_key);
    
    self.ref = [[FIRDatabase database] reference];
   
    [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
       // NSLog(@"DICT %@",dict);
        
        myHostLatitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Host Latitude"]];
        myHostLongitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Host Longitude"]];
        myGuestLatitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Guest Latitude"]];
        myGuestLongitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Guest Longitude"]];
        myGuestStatus = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Guest Location Status"]];
        
        
        
        myGuestFirstName = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Receiver First Name"]];
        myHostFirstName = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Sender First Name"]];
        myHostLastName = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Sender Last Name"]];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    
    while([myHostLatitude floatValue] == 0.0 && [myHostLongitude floatValue] == 0.0 && [myGuestLatitude floatValue] == 0.0 && [myGuestLongitude floatValue] == 0.0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    hostLatitude = myHostLatitude;
    hostLongitude = myHostLongitude;
    guestLatitude = myGuestLatitude;
    guestLongitude = myGuestLongitude;
    guestStatus = myGuestStatus;
    
    guestFirstName = myGuestFirstName;
    hostFirstName = myHostFirstName;
    hostLastName = myHostLastName;

    
     CLLocation *hostLoc = [[CLLocation alloc] initWithLatitude:[hostLatitude floatValue] longitude:[hostLongitude floatValue]];
    
     CLLocation *guestLoc = [[CLLocation alloc] initWithLatitude:[guestLatitude floatValue] longitude:[guestLongitude floatValue]];
    
    totalDistance = [guestLoc distanceFromLocation:hostLoc]*0.000621371;
    
   // NSLog(@"HOSt Lat Long is %f %f",[hostLatitude floatValue],[hostLongitude floatValue]);
   // NSLog(@"Total Distance is %f",totalDistance);
   // NSLog(@"Guest Satus is %@",guestStatus);
    
    
    
   // NSLog(@"TOTAL DIST");
}

/*
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self.indicator stopAnimating];
    self.indicator.hidden = TRUE;
}
*/
- (void)viewDidLoad {
    [super viewDidLoad];
    
   // NSLog(@"View DID LOAD");
    
    self.mapView.delegate = self;
    
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view from its nib.
    
    // Create Navigation BAR
    
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_myGuestsLocationBack];
    
   // self.indicator.hidden = FALSE;
    
    // Call calculate Total Distance
    
    [self findTotalDist];
    
    // IF NOT STARTED
    
    
    
    
    
    
    
}


-(void) centerMap:(MKPointAnnotation *)centerPoint{
    
    [self.mapView setCenterCoordinate:centerPoint.coordinate animated:YES];
}


-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == self.mapView.userLocation)
        return nil;
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"asdf"];
    
    if (pin == nil)
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"asdf"];
    else
        pin.annotation = annotation;
    
    if ([annotation.title isEqualToString:@"Your Location"]) {
        pin.pinTintColor = [UIColor colorWithRed:34.0f/255.0f green:139.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
        // pin.image=[UIImage imageNamed:@"arrest.png"] ;
    }

    [pin setAnimatesDrop:YES];
    [pin setEnabled:YES];
    [pin setCanShowCallout:YES];
    return pin;
}



-(void) addAnnotations {
    
    
   
    //NSLog(@"GUEST LATITIDE %f",[guestLatitude floatValue]);
  // NSLog(@"GUEST LONGITUDE %f",[guestLongitude floatValue]);
    
    self.yourLocationAnno = [[MKPointAnnotation alloc]init];
    
    self.yourLocationAnno.coordinate = CLLocationCoordinate2DMake([hostLatitude floatValue],[hostLongitude floatValue]);
    
    self.yourLocationAnno.title = @"Your Location";

    
    
    self.guestLocationAnno = [[MKPointAnnotation alloc]init];
    
    self.guestLocationAnno.coordinate = CLLocationCoordinate2DMake([guestLatitude floatValue],[guestLongitude floatValue]);
    
    self.guestLocationAnno.title = @"Guest Location";
    
    [self.mapView addAnnotations:@[self.yourLocationAnno,self.guestLocationAnno]];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (IBAction)Back
{
    
    NSLog(@"Back Tapped");
    TrackMyGuestsViewController *trackGuestsVC =
    [[TrackMyGuestsViewController alloc] initWithNibName:@"TrackMyGuestsViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:trackGuestsVC animated:YES];
    
    [self presentViewController:trackGuestsVC animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
