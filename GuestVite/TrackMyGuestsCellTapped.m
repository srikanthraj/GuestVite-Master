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


@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong,nonatomic) MKPointAnnotation *guestLocationAnno;

@property (strong,nonatomic) MKPointAnnotation *yourLocationAnno;

@property (nonatomic, strong) CNPPopupController *popupController;


@property (weak, nonatomic) IBOutlet UINavigationBar *myGuestsLocationBack;

@property(nonatomic,assign) BOOL mapIsMoving;

@property (strong, nonatomic) FIRDatabaseReference *ref;


@end

@implementation TrackMyGuestsCellTapped

NSMutableString *hostLatitude;
NSMutableString *hostLongitude;
NSMutableString *guestLatitude;
NSMutableString *guestLongitude;
NSMutableString *guestStatus;

float totalDistance;

-(void) viewWillAppear{
    [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width,80.0)];
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
    
    }

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Create Navigation BAR
    
    
    self.myGuestsLocationBack = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 400, 64)];
    
    [self.myGuestsLocationBack setFrame:CGRectMake(0, 0, 400, 64)];
    
    self.myGuestsLocationBack.translucent = YES;
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"navbar_bg"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
    
    
    
    self.backLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:10.0];
    self.backLabel.textColor = [UIColor whiteColor];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_myGuestsLocationBack];
    
    
    
    // Call Refresh Location once
    
    self.mapIsMoving  = NO;
    self.mapView.camera.altitude *= 1.4;
    [self refreshLocation];
    
    CLLocation *sourceLoc = [[CLLocation alloc] initWithLatitude:[guestLatitude floatValue] longitude:[guestLongitude floatValue]];
    
    
    CLLocation *destLoc = [[CLLocation alloc] initWithLatitude:[hostLatitude floatValue] longitude:[hostLongitude floatValue]];
    
    totalDistance = [sourceLoc distanceFromLocation:destLoc]*0.000621371;
    
    NSLog(@"ORIGINAl TOTAL DISTANCE IS %f",totalDistance);

    
    
    
    /*
    
    if([guestStatus isEqualToString:@"NOT_STARTED"])
    {
        
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Guest Not started yet"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }
    
    if([guestStatus isEqualToString:@"REACHED"])
    {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Guest is very close to your location or ha reached"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    
    if([guestStatus isEqualToString:@"IN_TRANSIT"])
    {
        
        */
        
        NSLog(@"DISTANCE BETWEEN SOURCE TO DESTINATION IS %f",[sourceLoc distanceFromLocation:destLoc]*0.000621371);
        
    
            
            [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refreshLocation) userInfo:nil repeats:YES];
    
    
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

- (IBAction)Back
{
    HomePageViewController *homePageVC =
    [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:homePageVC animated:YES];
    
    [self presentViewController:homePageVC animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
