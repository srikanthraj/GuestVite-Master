//
//  TrackMyGuestsCellTapped.m
//  GuestVite
//
//  Created by admin on 2016-11-06.
//  Copyright © 2016 admin. All rights reserved.
//

#import "TrackMyGuestsCellTapped.h"
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

-(void) viewWillAppear{
    [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width,80.0)];
}


-(void)refreshLocation {
    
    hostLatitude = [[NSMutableString alloc]init];
    hostLongitude = [[NSMutableString alloc]init];
    guestLatitude = [[NSMutableString alloc]init];
    guestLongitude = [[NSMutableString alloc]init];
    
    __block NSMutableString *myHostLatitude = [[NSMutableString alloc]init];
    
    __block NSMutableString *myHostLongitude = [[NSMutableString alloc]init];
    
    __block NSMutableString *myGuestLatitude = [[NSMutableString alloc]init];;
    
    __block NSMutableString *myGuestLongitude = [[NSMutableString alloc]init];;
    
    
    self.ref = [[FIRDatabase database] reference];
    
   
    
    [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        //NSLog(@"DICT %@",dict);
        
        myHostLatitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Host Latitude"]];
        myHostLongitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Host Longitude"]];
        myGuestLatitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Guest Latitude"]];
        myGuestLongitude = [NSMutableString stringWithFormat:@"%@",[dict valueForKey:@"Guest Longitude"]];
        
        
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
    
    
    
    [self addAnnotations];
    
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    
    
    /*
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
    */
    //[self centerMap:self.guestLocationAnno];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    // IF Guest has NOT YET STARTED from their place, Present a POP UP and give an option to remind the Guest
    
     self.ref = [[FIRDatabase database] reference];
    
    [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        if([[dict valueForKey:@"Guest Location Status"] isEqualToString:@"NOT_STARTED"])
        {
            
            NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            
            NSAttributedString *title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Looks Like %@ has not yet started from their Location",[dict valueForKey:@"Receiver First Name"]] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
            
            NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"How about checking back in some time?" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
            
            
            CNPPopupButton *gotItButton = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
            [gotItButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            gotItButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            [gotItButton setTitle:@"OK , Got it!" forState:UIControlStateNormal];
            gotItButton.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
            gotItButton.layer.cornerRadius = 4;
            gotItButton.selectionHandler = ^(CNPPopupButton *gotItButton){
                [self.popupController dismissPopupControllerAnimated:YES];
                
            };
            
            CNPPopupButton *reminderButton = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
            [reminderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            reminderButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            [reminderButton setTitle:@"Send a Reminder" forState:UIControlStateNormal];
            reminderButton.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
            reminderButton.layer.cornerRadius = 4;
            reminderButton.selectionHandler = ^(CNPPopupButton *reminderButton){
                
                
                // a. Send Message
                
                
                
                //Check for SMS and Send It
                
                if(!([[dict valueForKey:@"Receiver Phone"] isEqualToString:@"BULK"]) && !([[dict valueForKey:@"Receiver Phone"]length] ==0))
                {
                    
                    
                    
                    
                    if(![MFMessageComposeViewController canSendText]) {
                        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                        
                        [ac addAction:aa];
                        [self presentViewController:ac animated:YES completion:nil];
                        return;
                    }
                    
                    
                    
                    
                    
                    NSArray *recipents = [NSArray arrayWithObject:[dict valueForKey:@"Receiver Phone"]];
                    
                    
                    NSString *message = [NSString stringWithFormat:@"Hey %@!,This is reminder for your invite by %@ %@ at their place. Please login/Register to GuestVite App for more Details ,Thanks!",[dict valueForKey:@"Receiver First Name"],[dict valueForKey:@"Sender First Name"],[dict valueForKey:@"Receiver Last Name"]];
                    
                    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                    messageController.messageComposeDelegate = self;
                    [messageController setRecipients:recipents];
                    [messageController setBody:message];
                    
                    
                    [self presentViewController:messageController animated:YES completion:nil];
                    
                    
                }
                
               else if(!([[dict valueForKey:@"Receiver EMail"] isEqualToString:@"BULK"]) && !([[dict valueForKey:@"Receiver EMail"]length] ==0))
                {
                    
                    //Send Email
                    
                    
                    // Email Subject
                    NSString *emailTitle = @"Message From GeuestVite";
                    // Email Content
                    NSString *messageBody = [NSString stringWithFormat:@"Hey %@!,This is reminder for your invite by %@ %@ at their place. Please login/Register to GuestVite App for more Details ,Thanks!",[dict valueForKey:@"Receiver First Name"],[dict valueForKey:@"Sender First Name"],[dict valueForKey:@"Receiver Last Name"]];
                    // To address
                    NSArray *toRecipents = [NSArray arrayWithObject:[dict valueForKey:@"Receiver EMail"]];
                    
                    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                    mc.mailComposeDelegate = self;
                    [mc setSubject:emailTitle];
                    [mc setMessageBody:messageBody isHTML:NO];
                    [mc setToRecipients:toRecipents];
                    
                    // Present mail view controller on screen
                    [self presentViewController:mc animated:YES completion:NULL];
                    
                }
                
                
                
                [self.popupController dismissPopupControllerAnimated:YES];
                
            };
            
            
            
            
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.numberOfLines = 0;
            titleLabel.attributedText = title;
            
            UILabel *lineOneLabel = [[UILabel alloc] init];
            lineOneLabel.numberOfLines = 0;
            lineOneLabel.attributedText = lineOne;
            
            self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, lineOneLabel,buttonYesMessage,buttonYes,buttonNoMessage]];
            self.popupController.theme = [CNPPopupTheme defaultTheme];
            self.popupController.theme.popupStyle = CNPPopupStyleCentered;
            self.popupController.delegate = self;
            [self.popupController presentPopupControllerAnimated:YES];
            
            
            
            
            
        }
        
        
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    

    
    
    //----------------------------
    
    self.mapIsMoving  = NO;
    self.mapView.camera.altitude *= 1.4;
    [self refreshLocation];
    
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
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
