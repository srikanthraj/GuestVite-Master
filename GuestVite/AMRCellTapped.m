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
#import "GuestMapViewController.h"

@import Firebase;

@interface AMRCellTapped () <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,CNPPopupControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *invitedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedTillLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *personalMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *acceptOrDeclineLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *pendingInvitationsBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@property (weak, nonatomic) IBOutlet UILabel *messageFromLabel;

@property (nonatomic, strong) CNPPopupController *popupController;

@property (strong, nonatomic) FIRDatabaseReference *ref;
//@property (strong, nonatomic) FIRDatabaseReference *geofireRef;




@end

@implementation AMRCellTapped

NSMutableString *myFName;
NSMutableString *myLName;
NSMutableString *myEMail;
NSMutableString *myPhone;

NSString *actionTaken;

UIView* loadingView;

float currentLatitude = 0.0;
float currentLongitude = 0.0;

- (void)viewDidLoad {
    [super viewDidLoad];
     [self setNeedsStatusBarAppearanceUpdate];
    
   // FIRDatabaseRef *geofireRef = [[FIRDatabase database] reference];
   // GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:geofireRef];
    
    
    myFName = [[NSMutableString alloc]init];
    myLName = [[NSMutableString alloc]init];
    myEMail = [[NSMutableString alloc]init];
    myPhone = [[NSMutableString alloc]init];
    actionTaken = [[NSString alloc]init];
    
    
    
    // Stylize the buttons
    
    self.acceptButton.layer.cornerRadius = 10.0;
    [[self.acceptButton layer] setBorderWidth:1.0f];
    [[self.acceptButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    self.declineButton.layer.cornerRadius = 10.0;
    [[self.declineButton layer] setBorderWidth:1.0f];
    [[self.declineButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
     // Stylize the buttons ends
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_pendingInvitationsBack];

    
    
     self.ref = [[FIRDatabase database] reference];
    
    // Get First Name  and Last Name  and E-Mail or phone of the person who loggeded in
    
    __block NSString *currentUserFName = [[NSString alloc] init];
    __block NSString *currentUserLName = [[NSString alloc] init];
    __block NSString *currentUserEMail = [[NSString alloc] init];
    __block NSString *currentUserPhone = [[NSString alloc] init];
    
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dictUser = snapshot.value;
        
        currentUserFName =  [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"First Name"]];
        currentUserLName =  [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"Last Name"]];
        currentUserEMail =  [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"EMail"]];
        currentUserPhone  = [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"Phone"]];
        
        
    }];
    while(([currentUserEMail length]== 0 || [currentUserPhone length] ==0) && [currentUserFName length] == 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    [myFName setString:currentUserFName];
    [myLName setString:currentUserLName];
    [myEMail setString:currentUserEMail];
    [myPhone setString:currentUserPhone];
    
    NSLog(@"My First name %@",myFName);
    NSLog(@"My Last name %@",myLName);
    NSLog(@"My E-Mail %@",myEMail);
    NSLog(@"My Phone %@",myPhone);
    // Ends
    
    self.invitedByLabel.text = [NSString stringWithFormat:@"%@ %@",_inviteByFirstName,_inviteByLastName];
    
    self.invitedOnLabel.text = _invitedOn;
    
    self.invitedTillLabel.text = _invitedTill;
    
    self.personalMessageLabel.text = _personalMessage;
    
    self.senderNameLabel.text = _inviteByFirstName;
    
    self.acceptOrDeclineLabel.text = @"";
    
    //If No personal Message , then remove the corresponsding labels
    
    if([self.personalMessageLabel.text isEqualToString:@"Personalized Message"]){
        self.messageFromLabel.hidden = YES;
        self.senderNameLabel.hidden = YES;
        self.personalMessageLabel.hidden = YES;
    }
    
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
    
   
    
    
    
    // If the user wants to decline
    
    CNPPopupButton *buttonYesMessage = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [buttonYesMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buttonYesMessage.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [buttonYesMessage setTitle:@"Decline" forState:UIControlStateNormal];
    buttonYesMessage.backgroundColor = [UIColor colorWithRed:1.0 green:0.231f blue:0.188 alpha:1.0];
    buttonYesMessage.layer.cornerRadius = 4;
    buttonYesMessage.selectionHandler = ^(CNPPopupButton *buttonYesMessage){
        
       
        //Update Action Taken
        
        actionTaken = @"Declined";
        
        // a. Send Message only if Host has permitted
        if([_informHost isEqualToString:@"YES"])
        [self sendMessageToHost:@"Declined"];
        
        
        
        //b.  Update the DB entry
        
        // If Decline confirmed , ONLY then go ahead and deckine
        
        [self updateDB:@"NOT_STARTED" withInvitationStatus:@"Declined"];
        
        
        [self.popupController dismissPopupControllerAnimated:YES];
        
        if([_informHost isEqualToString:@"NO"]){
            
            self.acceptOrDeclineLabel.text = @"Invitation Declined";
            self.acceptOrDeclineLabel.textColor = [UIColor redColor];
            [self performSelector:@selector(loadingNextView)
                       withObject:nil afterDelay:3.0f];
        }
        
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
        
    };
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
  
    
       self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel,buttonYesMessage,buttonNoMessage]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
    
    
    
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)acceptTapped:(id)sender {
    
    
    
    //Update Action Taken
    
    actionTaken = @"Accepted";
    
    // a. Send Message only if Host has permitted
    
    if([_informHost isEqualToString:@"YES"])
    [self sendMessageToHost:@"Accepted"];

    //b.  Update the DB entry
   
    [self updateDB:@"NOT_STARTED" withInvitationStatus:@"Accepted"];
    
    if([_informHost isEqualToString:@"NO"]){
        
        self.acceptOrDeclineLabel.text = [NSString stringWithFormat:@"Invitation Accepted, You can go to My Accepted Invites when you want to start to %@'s place",_inviteByFirstName];
        self.acceptOrDeclineLabel.textColor = [UIColor greenColor];
        
        [self performSelector:@selector(loadingNextView)
                   withObject:nil afterDelay:4.0f];
    }

    
    
}


-(void) sendMessageToHost:(NSString *)action {
    
    
    
    //Check for SMS and Send It
    
    if(!([_hostPhone isEqualToString:@"Not Specified"]))
    {
        
        
        
        
        if(![MFMessageComposeViewController canSendText]) {
          
            UIAlertController *ac = [UIAlertController  alertControllerWithTitle:@"GuestVite" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
        
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * myaction){
                //If Declined
                if([action isEqualToString:@"Declined"])
                {
                    self.acceptOrDeclineLabel.text = @"Invitation Declined";
                    self.acceptOrDeclineLabel.textColor = [UIColor redColor];
                    [self performSelector:@selector(loadingNextView)
                               withObject:nil afterDelay:3.0f];
                    
                }
                
                // If Accepted
                
                else if([action isEqualToString:@"Accepted"])
                {
                    self.acceptOrDeclineLabel.text = [NSString stringWithFormat:@"Invitation Accepted, You can go to My Accepted Invites when you want to start to %@'s place",_inviteByFirstName];
                    self.acceptOrDeclineLabel.textColor = [UIColor greenColor];
                    
                    [self performSelector:@selector(loadingNextView)
                               withObject:nil afterDelay:10.0f];
                }

            }];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            return;
        }
        
        
        
        
        
        NSArray *recipents = [NSArray arrayWithObject:_hostPhone];
        
        NSString *message = [[NSString alloc]init];
        if([action isEqualToString:@"Declined"])
            {
        
        message = [NSString stringWithFormat:@"Hey %@!, This is %@ and I am extremely sorry that I would not be able to make it this time , May be next time!",_inviteByFirstName,myFName];
            
            
            }
        
        
        
        else if([action isEqualToString:@"Accepted"]){
            
       
        message = [NSString stringWithFormat:@"Hey %@!, This is %@ and Thank You for the invite, We will be there at your place",_inviteByFirstName,myFName];
            
            
        }
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipents];
        [messageController setBody:message];
        
        
        [self presentViewController:messageController animated:YES completion:nil];
        
        
    }
    
    else if(!([_hostEMail isEqualToString:@"Not Specified"]))
    {
        
        
        //Send Email
        
        NSLog(@"Device Cant send Text , So End E-Mail");
        // Email Subject
        NSString *emailTitle = @"Message From GuestVite";
        // Email Content
        
        NSString *messageBody = [[NSString alloc]init];
        if([action isEqualToString:@"Declined"])
        {

        messageBody = [NSString stringWithFormat:@"Hey %@!, This is %@ and I am extremely sorry that I would not be able to make it this time , May be next time!",_inviteByFirstName,myFName];
        }
        else if([action isEqualToString:@"Accepted"]) {
            
        messageBody = [NSString stringWithFormat:@"Hey %@!, This is %@ and Thank You for the invite, We will be there at your place",_inviteByFirstName,myFName];
        }
        
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

    
    
    
}

-(void)updateDB :(NSString *)guestLocationStatus withInvitationStatus:(NSString *)guestReply
{

// Update DB to Accepted

[[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    
    NSDictionary *dict = snapshot.value;
    
    
    NSString *hostaddr = [[NSString alloc]init];
    
    if([[dict valueForKey:@"Sender Address2"] length] > 0)
    {
        hostaddr = [NSString stringWithFormat:@"%@,%@,%@,%@",[dict valueForKey:@"Sender Address1"],[dict valueForKey:@"Sender Address2"],[dict valueForKey:@"Sender City"],[dict valueForKey:@"Sender Zip"]];
    }
    
    else {
        hostaddr = [NSString stringWithFormat:@"%@,%@,%@",[dict valueForKey:@"Sender Address1"],[dict valueForKey:@"Sender City"],[dict valueForKey:@"Sender Zip"]];
    }
    
    CLLocationCoordinate2D dest = [self geoCodeUsingAddress:hostaddr];
    
    
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
                               @"Invitation Status": guestReply,
                               @"Host Latitude": [NSNumber numberWithFloat:dest.latitude],
                               @"Host Longitude": [NSNumber numberWithFloat:dest.longitude],
                               @"Guest Location Status" : guestLocationStatus,
                               @"Host Send Messages" : _informHost,
                               };//Dict post
    
    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", _key]: postDict};
    [_ref updateChildValues:childUpdates];
    
    //NSLog(@"Value After decline %@" , [dict valueForKey:@"Invitation Status"]);
    
    
}];

}

- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
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
        case MessageComposeResultCancelled: {
            
            //If Declined
            if([actionTaken isEqualToString:@"Declined"])
            {
                self.acceptOrDeclineLabel.text = @"Invitation Declined";
                self.acceptOrDeclineLabel.textColor = [UIColor redColor];
                [self performSelector:@selector(loadingNextView)
                           withObject:nil afterDelay:3.0f];
                
            }
            
            // If Accepted
            
            else if([actionTaken isEqualToString:@"Accepted"])
            {
                self.acceptOrDeclineLabel.text = [NSString stringWithFormat:@"Invitation Accepted, You can go to My Accepted Invites when you want to start to %@'s place",_inviteByFirstName];
                self.acceptOrDeclineLabel.textColor = [UIColor greenColor];
                
                [self performSelector:@selector(loadingNextView)
                           withObject:nil afterDelay:4.0f];
            }

            
            break;
        }
            
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
            
            // If Declined
            
            if([actionTaken isEqualToString:@"Declined"])
            {
            self.acceptOrDeclineLabel.text = @"Invitation Declined";
            self.acceptOrDeclineLabel.textColor = [UIColor redColor];
            
            [self performSelector:@selector(loadingNextView)
                       withObject:nil afterDelay:3.0f];
            }
            
            // If Accepted
            
            else if([actionTaken isEqualToString:@"Accepted"])
            {
                self.acceptOrDeclineLabel.text = [NSString stringWithFormat:@"Invitation Accepted, You can go to My Accepted Invites when you want to start to %@'s place",_inviteByFirstName];
                self.acceptOrDeclineLabel.textColor = [UIColor greenColor];
                
                [self performSelector:@selector(loadingNextView)
                           withObject:nil afterDelay:4.0f];
            }
            
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
        case MFMailComposeResultCancelled: {
            
            
            //If Declined
            if([actionTaken isEqualToString:@"Declined"])
            {
                self.acceptOrDeclineLabel.text = @"Invitation Declined";
                self.acceptOrDeclineLabel.textColor = [UIColor redColor];
                [self performSelector:@selector(loadingNextView)
                           withObject:nil afterDelay:3.0f];
                
            }
            
            // If Accepted
            
            else if([actionTaken isEqualToString:@"Accepted"])
            {
                self.acceptOrDeclineLabel.text = [NSString stringWithFormat:@"Invitation Accepted, You can go to My Accepted Invites when you want to start to %@'s place",_inviteByFirstName];
                self.acceptOrDeclineLabel.textColor = [UIColor greenColor];
                
                [self performSelector:@selector(loadingNextView)
                           withObject:nil afterDelay:4.0f];
            }
            
            break;
        }
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent: {
           
           
            //If Declined
            if([actionTaken isEqualToString:@"Declined"])
            {
            self.acceptOrDeclineLabel.text = @"Invitation Declined";
            self.acceptOrDeclineLabel.textColor = [UIColor redColor];
            [self performSelector:@selector(loadingNextView)
                       withObject:nil afterDelay:3.0f];
            
            }
            
            // If Accepted
            
            else if([actionTaken isEqualToString:@"Accepted"])
            {
                self.acceptOrDeclineLabel.text = [NSString stringWithFormat:@"Invitation Accepted, You can go to My Accepted Invites when you want to start to %@'s place",_inviteByFirstName];
                self.acceptOrDeclineLabel.textColor = [UIColor greenColor];
                
                [self performSelector:@selector(loadingNextView)
                           withObject:nil afterDelay:4.0f];
            }

            
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
