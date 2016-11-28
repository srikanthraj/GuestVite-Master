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
    
    
    if ([guestStatus isEqualToString:@"REACHED"]) {
        
        
        NSLog(@"SHOW THIS!!");
        
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
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Guest Not started yet"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }

    
    // IF GUEST IN TRANSIT
    
    else if([guestStatus isEqualToString:@"IN_TRANSIT"]){
        
        self.mapIsMoving  = NO;
        self.mapView.camera.altitude *= 1.4;
        
        newTimer =  [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(refreshLocation) userInfo:nil repeats:YES];
        
            }

    
    
    
    NSLog(@"View Did apperar");
    [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width,80.0)];
}


-(NSString *) findETA:(CLLocationDegrees)destLatitude withDestLongitude:(CLLocationDegrees)destLongitude withSourceLatitude:(CLLocationDegrees)sourceLatitude withSourceLongitude:(CLLocationDegrees)sourceLongitude{
    
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(sourceLatitude,sourceLongitude) addressDictionary:nil];
    
    [request setSource:[[MKMapItem alloc] initWithPlacemark:sourcePlacemark]];
    
    
    MKPlacemark *destPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(destLatitude,destLongitude) addressDictionary:nil];
    
    [request setDestination:[[MKMapItem alloc] initWithPlacemark:destPlacemark]];
    
    __block NSString *myETA = [[NSString alloc] init];
    
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    [request setRequestsAlternateRoutes:NO];
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if ( ! error && [response routes] > 0) {
            MKRoute *route = [[response routes] objectAtIndex:0];
            //NSLog(@"Distance is %f" ,route.distance * 0.000621371);
            NSLog(@"ETA INSIDE FUNCTION IS %f",route.expectedTravelTime/60);
            myETA = [NSString stringWithFormat:@"%f",route.expectedTravelTime/60];
            
        }
    }];
    
    while([myETA length] == 0){
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        NSLog(@"In Loop");
    }
    NSLog(@"ETA OUTSIDE FUNCTION IS %@",myETA);
    return(myETA);
}



-(void)refreshLocation {
    
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
    
    NSString *eta = [self findETA:[hostLatitude doubleValue] withDestLongitude: [hostLongitude doubleValue] withSourceLatitude: [guestLatitude doubleValue] withSourceLongitude:[guestLongitude doubleValue]];
    //Update ETA
    NSLog(@"ETA IS %@",eta);
    // Change eta to time
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setMinute:[eta integerValue]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *myNewDate=[calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    
    self.etaTimeLabel.text = [formatter stringFromDate:myNewDate];
   
    NSLog(@"Guest Status inside refresh Location is %@",guestStatus);
    
    
    // If Guest nearing - Remaining Distance < 10% of Total Distance
    
    if([[[CLLocation alloc] initWithLatitude:[hostLatitude floatValue] longitude:[hostLongitude floatValue]] distanceFromLocation:[[CLLocation alloc] initWithLatitude:[guestLatitude floatValue] longitude:[guestLongitude floatValue]]] < 0.1 * totalDistance){
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Your Guest is nearing your place, Enjoy your time!"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }
    
    
    
    // If Guest reached Destination
    
    if([guestStatus isEqualToString:@"REACHED"]){
        
        NSLog(@"Going inside here");
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
    
    NSLog(@"KEY %@",_key);
    
    self.ref = [[FIRDatabase database] reference];
   
    [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        NSLog(@"DICT %@",dict);
        
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
    
    NSLog(@"Total Distance is %f",totalDistance);
    NSLog(@"Guest Satus is %@",guestStatus);
    
    
    
    NSLog(@"TOTAL DIST");
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view from its nib.
    
    // Create Navigation BAR
    
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_myGuestsLocationBack];
    
    
    
    
    
    // Call calculate Total Distance
    
    [self findTotalDist];
    
    // IF NOT STARTED
    
    
    
    
    
    
    
}


-(void) centerMap:(MKPointAnnotation *)centerPoint{
    
    [self.mapView setCenterCoordinate:centerPoint.coordinate animated:YES];
}


-(void) addAnnotations {
    
    
   
    NSLog(@"GUEST LATITIDE %f",[guestLatitude floatValue]);
    NSLog(@"GUEST LONGITUDE %f",[guestLongitude floatValue]);
    
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
