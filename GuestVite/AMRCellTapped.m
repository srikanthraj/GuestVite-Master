//
//  AMRCellTapped.m
//  GuestVite
//
//  Created by admin on 2016-10-26.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AMRCellTapped.h"
#include "AwaitMyResponseViewController.h"
#import "CNPPopupController.h"
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import "MapKit/MapKit.h"

@import Firebase;

@interface AMRCellTapped () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *invitedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedTillLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *personalMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *acceptOrDeclineLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *pendingInvitationsBack;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property(strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CNPPopupController *popupController;

@property (strong, nonatomic) FIRDatabaseReference *ref;





@end

@implementation AMRCellTapped


float currentLatitude = 0.0;
float currentLongitude = 0.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the location Manager
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.pendingInvitationsBack = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 400, 64)];
    
    [self.pendingInvitationsBack setFrame:CGRectMake(0, 0, 400, 64)];
    
    self.pendingInvitationsBack.translucent = YES;
    
    
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
    
    [self.view addSubview:_pendingInvitationsBack];

    
    
     self.ref = [[FIRDatabase database] reference];
    self.invitedByLabel.text = [NSString stringWithFormat:@"%@ %@",_inviteByFirstName,_inviteByLastName];
    
    self.invitedOnLabel.text = _invitedOn;
    
    self.invitedTillLabel.text = _invitedTill;
    
    self.personalMessageLabel.text = _personalMessage;
    
    self.senderNameLabel.text = _inviteByFirstName;
    
    self.acceptOrDeclineLabel.text = @"";
}


- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)declineTapped:(id)sender {
    
    //NSString *pkey = [NSString stringWithFormat:@"%@",[[_ref child:@"invites"] child:_key]];
    
    // Case of Invite Declined - Update the status to DECLINED
    
    // 1.  First ask if the user really wants to decline or not
    
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Do You really want to Decline this Invite?" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"If Yes, How about sending a sorry message to your Host?" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
    
    /*
     NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"Simply delete this message if you do not want to send one" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
     */
    
    
    
    // If the user wants to send a message and decline
    
    CNPPopupButton *buttonYesMessage = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [buttonYesMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buttonYesMessage.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [buttonYesMessage setTitle:@"Decline & Message" forState:UIControlStateNormal];
    buttonYesMessage.backgroundColor = [UIColor colorWithRed:1.0 green:0.231f blue:0.188 alpha:1.0];
    buttonYesMessage.layer.cornerRadius = 4;
    buttonYesMessage.selectionHandler = ^(CNPPopupButton *buttonYesMessage){
        
        //NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
        
        //NSLog(@"HOST EMAIL %@",_hostEMail);
       // NSLog(@"HOST PHONE %@",_hostPhone);
        
        
        // a. Send Message
        
        
            
            
            //Check for SMS and Send It
            
            if(!([_hostPhone isEqualToString:@"Not Specified"]))
            {
                
                
                
                
                if(![MFMessageComposeViewController canSendText]) {
                    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    
                    [ac addAction:aa];
                    [self presentViewController:ac animated:YES completion:nil];
                    return;
                }
                
                
                
                
                
                NSArray *recipents = [NSArray arrayWithObject:_hostPhone];
                
                
                NSString *message = [NSString stringWithFormat:@"Hey %@!, I am extremely sorry that I would not be able to make it this time , May be next time!",_inviteByFirstName];
                
                MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                messageController.messageComposeDelegate = self;
                [messageController setRecipients:recipents];
                [messageController setBody:message];
                
                
                [self presentViewController:messageController animated:YES completion:nil];
                
                
            }
        
        if(!([_hostEMail isEqualToString:@"Not Specified"]))
        {
            
            //Send Email
            
            
            // Email Subject
            NSString *emailTitle = @"Message From GeuestVite";
            // Email Content
            NSString *messageBody = [NSString stringWithFormat:@"Hey %@!, I am extremely sorry that I would not be able to make it this time , May be next time!",_inviteByFirstName];
            // To address
            NSArray *toRecipents = [NSArray arrayWithObject:_hostEMail];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            
        }
        
        
        
        
        //b.  Remove the DB entry
        
        // If Decline confirmed , ONLY then go ahead and delete
        
        
        
        [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
            
            //NSLog(@"DICT %@",dict);
            
            //NSLog(@"Value Before decline %@" , [dict valueForKey:@"Invitation Status"]);
            NSDictionary *postDict = @{@"Sender First Name": [dict valueForKey:@"Sender First Name"],
                                       @"Sender Last Name": [dict valueForKey:@"Sender Last Name"],
                                       @"Sender EMail": [dict valueForKey:@"Sender EMail"],
                                       @"Sender Address1": [dict valueForKey:@"Sender Address1"],
                                       @"Sender Address2": [dict valueForKey:@"Sender Address2"],
                                       @"Sender City": [dict valueForKey:@"Sender City"],
                                       @"Sender Zip": [dict valueForKey:@"Sender Zip"],
                                       @"Sender Phone": [dict valueForKey:@"Sender Phone"],
                                       @"Mesage From Sender": [dict valueForKey:@"Mesage From Sender"],
                                       @"Receiver First Name": [dict valueForKey:@"Receiver First Name"],
                                       @"Receiver Last Name": [dict valueForKey:@"Receiver Last Name"],
                                       @"Receiver EMail": [dict valueForKey:@"Receiver EMail"],
                                       @"Receiver Phone": [dict valueForKey:@"Receiver Phone"],
                                       @"Invite For Date": [dict valueForKey:@"Invite For Date"],
                                       @"Invite Valid Till Date": [dict valueForKey:@"Invite Valid Till Date"],
                                       @"Invitation Status": @"Declined",
                                       };//Dict post
            
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", _key]: postDict};
            [_ref updateChildValues:childUpdates];
            
            //NSLog(@"Value After decline %@" , [dict valueForKey:@"Invitation Status"]);
            
            
        }];

        
        
        
        
        [self.popupController dismissPopupControllerAnimated:YES];
        //NSLog(@"Block for button: %@", buttonYesMessage.titleLabel.text);
    };
    
    
    // If the user just wants to decline
    
    CNPPopupButton *buttonYes = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [buttonYes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buttonYes.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [buttonYes setTitle:@"Just Decline" forState:UIControlStateNormal];
    buttonYes.backgroundColor = [UIColor colorWithRed:1.0 green:0.231f blue:0.188 alpha:1.0];
    buttonYes.layer.cornerRadius = 4;
    buttonYes.selectionHandler = ^(CNPPopupButton *buttonYes){
        
        // If Decline confirmed , ONLY then go ahead and delete the Db entry
        
        [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
            
            //NSLog(@"DICT %@",dict);
            
            //NSLog(@"Value Before decline %@" , [dict valueForKey:@"Invitation Status"]);
            NSDictionary *postDict = @{@"Sender First Name": [dict valueForKey:@"Sender First Name"],
                                       @"Sender Last Name": [dict valueForKey:@"Sender Last Name"],
                                       @"Sender EMail": [dict valueForKey:@"Sender EMail"],
                                       @"Sender Address1": [dict valueForKey:@"Sender Address1"],
                                       @"Sender Address2": [dict valueForKey:@"Sender Address2"],
                                       @"Sender City": [dict valueForKey:@"Sender City"],
                                       @"Sender Zip": [dict valueForKey:@"Sender Zip"],
                                       @"Sender Phone": [dict valueForKey:@"Sender Phone"],
                                       @"Mesage From Sender": [dict valueForKey:@"Mesage From Sender"],
                                       @"Receiver First Name": [dict valueForKey:@"Receiver First Name"],
                                       @"Receiver Last Name": [dict valueForKey:@"Receiver Last Name"],
                                       @"Receiver EMail": [dict valueForKey:@"Receiver EMail"],
                                       @"Receiver Phone": [dict valueForKey:@"Receiver Phone"],
                                       @"Invite For Date": [dict valueForKey:@"Invite For Date"],
                                       @"Invite Valid Till Date": [dict valueForKey:@"Invite Valid Till Date"],
                                       @"Invitation Status": @"Declined",
                                       };//Dict post
            
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", _key]: postDict};
            [_ref updateChildValues:childUpdates];
            
            //NSLog(@"Value After decline %@" , [dict valueForKey:@"Invitation Status"]);
            
            
        }];

        
        
        [self.popupController dismissPopupControllerAnimated:YES];
        //NSLog(@"Block for button: %@", buttonYes.titleLabel.text);
        self.acceptOrDeclineLabel.text = @"Invitation Declined";
        self.acceptOrDeclineLabel.textColor = [UIColor redColor];
        
        
        [self performSelector:@selector(loadingNextView)
                   withObject:nil afterDelay:3.0f];
    };
    
    
    // If the user changes mind
    
    CNPPopupButton *buttonNoMessage = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [buttonNoMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buttonNoMessage.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [buttonNoMessage setTitle:@"Go Back" forState:UIControlStateNormal];
    buttonNoMessage.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    buttonNoMessage.layer.cornerRadius = 4;
    buttonNoMessage.selectionHandler = ^(CNPPopupButton *buttonNoMessage){
        [self.popupController dismissPopupControllerAnimated:YES];
        //NSLog(@"Block for button: %@", buttonNoMessage.titleLabel.text);
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

- (IBAction)acceptTapped:(id)sender {
    
    [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        
        NSDictionary *postDict = @{@"Sender First Name": [dict valueForKey:@"Sender First Name"],
                                   @"Sender Last Name": [dict valueForKey:@"Sender Last Name"],
                                   @"Sender EMail": [dict valueForKey:@"Sender EMail"],
                                   @"Sender Address1": [dict valueForKey:@"Sender Address1"],
                                   @"Sender Address2": [dict valueForKey:@"Sender Address2"],
                                   @"Sender City": [dict valueForKey:@"Sender City"],
                                   @"Sender Zip": [dict valueForKey:@"Sender Zip"],
                                   @"Sender Phone": [dict valueForKey:@"Sender Phone"],
                                   @"Mesage From Sender": [dict valueForKey:@"Mesage From Sender"],
                                   @"Receiver First Name": [dict valueForKey:@"Receiver First Name"],
                                   @"Receiver Last Name": [dict valueForKey:@"Receiver Last Name"],
                                   @"Receiver EMail": [dict valueForKey:@"Receiver EMail"],
                                   @"Receiver Phone": [dict valueForKey:@"Receiver Phone"],
                                   @"Invite For Date": [dict valueForKey:@"Invite For Date"],
                                   @"Invite Valid Till Date": [dict valueForKey:@"Invite Valid Till Date"],
                                   @"Invitation Status": @"Accepted",
                                   };//Dict post

        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", _key]: postDict};
        [_ref updateChildValues:childUpdates];
           }];
        
        // Show popup
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Your Acceptance is on its way!" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
        
        
        CNPPopupButton *startToHostPlaceButton = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
        [startToHostPlaceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        startToHostPlaceButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [startToHostPlaceButton setTitle:[NSString stringWithFormat:@"%@'s place!",self.inviteByFirstName] forState:UIControlStateNormal];
        startToHostPlaceButton.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
        startToHostPlaceButton.layer.cornerRadius = 4;
        startToHostPlaceButton.selectionHandler = ^(CNPPopupButton *startToHostPlaceButton){
            
            
            // Open of Maps Part starts
            
            //Check the availability of the Google Maps app on the device
            
            if (![[UIApplication sharedApplication] canOpenURL:
                 [NSURL URLWithString:@"comgooglemaps://"]]) {
                NSLog(@"Your Device does not have Google Maps");
            }
            
            else { // If device has Google Maps
                
                //1. Get guest's current location
                
                self.locationManager = [[CLLocationManager alloc]init];
                self.locationManager.delegate = self;
                [self.locationManager requestWhenInUseAuthorization];
                [self.locationManager startUpdatingLocation];
                while(currentLatitude == 0.0 && currentLongitude == 0.0){ // Wait till latitude and longitude gets populated
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                }
                
                
                //Once latitude and Longitude gets populated - Stop getting location updates
                [self.locationManager stopUpdatingLocation];
                
                
                NSLog(@"LATITUDE %f",currentLatitude);
                NSLog(@"LONGITUDE %f",currentLongitude);
                
                CLLocationCoordinate2D dest = [self geoCodeUsingAddress:@"1500 American Boulevard, Pennington, NJ 08534"];
                
                NSLog(@"Destination Latitude %f",dest.latitude);
                NSLog(@"Destination Longitude %f",dest.longitude);
                
                NSString *address = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving",currentLatitude,currentLongitude,dest.latitude,dest.longitude];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
                
                
            }
            
            
            
            
            //Open of Maps part Ends
            
            
            
      
            [self.popupController dismissPopupControllerAnimated:YES];
            NSLog(@"Block for button: %@", startToHostPlaceButton.titleLabel.text);
            self.acceptOrDeclineLabel.text = @"Invitation Accepted";
            self.acceptOrDeclineLabel.textColor = [UIColor greenColor];
            
            
            [self performSelector:@selector(loadingNextView)
                       withObject:nil afterDelay:3.0f];
            

        };
    
    
    CNPPopupButton *goBackButton = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [goBackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    goBackButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [goBackButton setTitle:@"Not Now" forState:UIControlStateNormal];
    goBackButton.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    goBackButton.layer.cornerRadius = 4;
    goBackButton.selectionHandler = ^(CNPPopupButton *goBackButton){
        [self.popupController dismissPopupControllerAnimated:YES];
        NSLog(@"Block for button: %@", goBackButton.titleLabel.text);
        self.acceptOrDeclineLabel.text = @"Invitation Accepted";
        self.acceptOrDeclineLabel.textColor = [UIColor greenColor];
        
        
        [self performSelector:@selector(loadingNextView)
                   withObject:nil afterDelay:3.0f];
        

    };
    
 
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel,startToHostPlaceButton,goBackButton]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];

    
    
}




- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    
   // NSLog(@"RESULU is %@",result);
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    currentLatitude = locations.lastObject.coordinate.latitude;
    currentLongitude = locations.lastObject.coordinate.longitude;
   NSLog(@"LATITUDE %f",currentLatitude);
   NSLog(@"LONGITUDE %f",currentLongitude);
    
    
}



- (void)loadingNextView{
    
    
    AwaitMyResponseViewController *amrVC =
    [[AwaitMyResponseViewController alloc] initWithNibName:@"AwaitMyResponseViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:amrVC animated:YES];
    
    [self presentViewController:amrVC animated:YES completion:nil];
    
    
    
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Failed to send SMS!" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            
            break;
        }
            
        case MessageComposeResultSent:
        {
            NSLog(@"SMS Sent");
            self.acceptOrDeclineLabel.text = @"Invitation Declined";
            self.acceptOrDeclineLabel.textColor = [UIColor redColor];
            
            
            [self performSelector:@selector(loadingNextView)
                       withObject:nil afterDelay:3.0f];
            break;
        }
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent: {
            NSLog(@"E-Mail Sent");
            self.acceptOrDeclineLabel.text = @"Invitation Declined";
            self.acceptOrDeclineLabel.textColor = [UIColor redColor];
            
            
            [self performSelector:@selector(loadingNextView)
                       withObject:nil afterDelay:3.0f];
            break;
        }
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



@end
