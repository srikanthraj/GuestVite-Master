//
//  MyAcceptedInvitesViewController.m
//  GuestVite
//
//  Created by admin on 2016-11-12.
//  Copyright © 2016 admin. All rights reserved.
//

#import "MyAcceptedInvitesViewController.h"
#import "SimpleTableCellTableViewCell.h"
#import "CNPPopupController.h"
#import "HomePageViewController.h"
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import "MapKit/MapKit.h"
#import "EmptyViewController.h"

@import Firebase;

@interface MyAcceptedInvitesViewController () <UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate,SWTableViewCellDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,CNPPopupControllerDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *myAcceptedInvitesBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property(strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) CNPPopupController *popupController;

@end

@implementation MyAcceptedInvitesViewController


float maicurrentLatitude = 0.0;
float maicurrentLongitude = 0.0;

NSInteger mySelectedRowNumber = 0;

EmptyViewController *maiEmptyView;
NSMutableArray *maifirstNameData;
NSMutableArray *mailastNameData;
NSMutableArray *maihostEMailData;
NSMutableArray *maihostPhoneData;
NSMutableArray *maiGuestLocationStatusData;
NSMutableArray *maihostAddLOne;
NSMutableArray *maihostAddLTwo;
NSMutableArray *maihostAddCity;
NSMutableArray *maihostAddZip;

NSMutableArray *maihostLatitude;
NSMutableArray *maihostLongitude;


NSMutableArray *maiinformHostData;

NSMutableArray *mainameData;
NSMutableArray *maiinvitedFromData;
NSMutableArray *maiinvitedTillData;
NSMutableArray *maikeyData;

NSArray *maikeys;

CLLocation *destLoc;

NSString *myAcceptedInviteSelcetedKey;

-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [dateFormatter setTimeZone:timeZone];
    return [dateFormatter dateFromString:dateStr];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view from its nib.
    
    // Initialize the location Manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate =self;
    
    
    
    maiEmptyView = [[EmptyViewController alloc]init];
    maifirstNameData = [[NSMutableArray alloc]init];
    mailastNameData = [[NSMutableArray alloc]init];
    maihostEMailData = [[NSMutableArray alloc]init];
    maihostPhoneData = [[NSMutableArray alloc]init];
    maiinformHostData = [[NSMutableArray alloc]init];
    maiGuestLocationStatusData = [[NSMutableArray alloc]init];
    maihostAddLOne = [[NSMutableArray alloc]init];
    maihostAddLTwo = [[NSMutableArray alloc]init];
    maihostAddCity = [[NSMutableArray alloc]init];
    maihostAddZip = [[NSMutableArray alloc]init];
    maihostLatitude = [[NSMutableArray alloc]init];
    maihostLongitude = [[NSMutableArray alloc]init];
    
    
    maiinvitedFromData = [[NSMutableArray alloc]init];
    maiinvitedTillData = [[NSMutableArray alloc]init];
    maikeyData = [[NSMutableArray alloc]init];
    
    myAcceptedInviteSelcetedKey = [[NSString alloc]init];
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_myAcceptedInvitesBack];
    
    maikeys = [[NSArray alloc]init];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    //NSLog(@"DATE IS %@",[NSDate date]);
    
    
    NSDate *loginDate = [self dateToFormatedDate:[dateFormatter stringFromDate:[NSDate date]]];
    
    
    __block NSMutableArray *myfirstNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *mylastNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostEMailData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostPhoneData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myGuestLocationStatusData = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *myhostAddLOne = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostAddLTwo = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostAddCity = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostAddZip = [[NSMutableArray alloc] init];
    __block NSMutableArray *myInformHostData = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *myhostLatitude = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostLongitude = [[NSMutableArray alloc] init];
    
    
    __block NSMutableArray *myinvitedFromData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedTillData = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *myKeyData = [[NSMutableArray alloc] init];
    
    
    __block NSString *currentUserEMail = [[NSString alloc] init];
    __block NSString *currentUserPhone = [[NSString alloc] init];
    
    __block NSUInteger inviteTableIterator;
    
    __block NSUInteger inviteTableLength;
    
    self.ref = [[FIRDatabase database] reference];
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dictUser = snapshot.value;
       
        currentUserEMail =  [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"EMail"]];
        currentUserPhone  = [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"Phone"]];
        
        
    }];
    while([currentUserEMail length]== 0 || [currentUserPhone length] ==0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    
    
    
    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        //NSString *startDateTime  = [[NSString alloc] init];
        NSString *endDateTime = [[NSString alloc] init];
        NSArray * arr = [dict allValues];
        maikeys = [dict allKeys];
        //NSLog(@"Array %@",arr[0][@"Sender First Name"]);
        
        // NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        //NSLog(@"ARR count %lu",(unsigned long)[arr count]);
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                fromDate:[self dateToFormatedDate:endDateTime]
                                                                  toDate:loginDate
                                                                 options:0];
            
            
            if([currentUserEMail length] > 0 && [arr[i][@"Invitation Status"] isEqualToString:@"Accepted"] && ([arr[i][@"Receiver EMail"] isEqualToString:currentUserEMail])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending))
            {
                
                if([components day] <= 5)
                {
                
                [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                [mylastNameData addObject:arr[i][@"Sender Last Name"]];
                [myhostEMailData addObject:arr[i][@"Sender EMail"]];
                [myhostPhoneData addObject:arr[i][@"Sender Phone"]];
                [myGuestLocationStatusData addObject:arr[i][@"Guest Location Status"]];
                [myhostAddLOne addObject: arr[i][@"Sender Address1"]];
                [myhostAddLTwo addObject:arr[i][@"Sender Address2"]];
                [myhostAddCity addObject:arr[i][@"Sender City"]];
                [myhostAddZip addObject:arr[i][@"Sender Zip"]];
                [myInformHostData addObject:arr[i][@"Host Send Messages"]];
                
                [myhostLatitude addObject:arr[i][@"Host Latitude"]];
                [myhostLongitude addObject:arr[i][@"Host Longitude"]];
                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                
                [myKeyData addObject:maikeys[i]];
                continue;
                
                }
            }
            
            
            if([currentUserPhone length] > 0 && [arr[i][@"Invitation Status"] isEqualToString:@"Accepted"] && ([arr[i][@"Receiver Phone"] isEqualToString:currentUserPhone])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending))
            {
                
                if([components day] <= 5)
                {
                
                [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                [mylastNameData addObject:arr[i][@"Sender Last Name"]];
                [myhostEMailData addObject:arr[i][@"Sender EMail"]];
                [myhostPhoneData addObject:arr[i][@"Sender Phone"]];
                [myGuestLocationStatusData addObject:arr[i][@"Guest Location Status"]];
                
                [myhostAddLOne addObject: arr[i][@"Sender Address1"]];
                [myhostAddLTwo addObject:arr[i][@"Sender Address2"]];
                [myhostAddCity addObject:arr[i][@"Sender City"]];
                [myhostAddZip addObject:arr[i][@"Sender Zip"]];
                [myInformHostData addObject:arr[i][@"Host Send Messages"]];
                
                [myhostLatitude addObject:arr[i][@"Host Latitude"]];
                [myhostLongitude addObject:arr[i][@"Host Longitude"]];

                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                
                [myKeyData addObject:maikeys[i]];
                
                continue;
                
            }
            
            }
            
            
            
            if(i == ([arr count]-1)){ // Check in case of last iteration and Add "No Invites" Only if no data is added to invites list
                
                
                //NSLog(@"Last Iteration");
                if([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0)
                {
                    [myfirstNameData addObject: @"No Invites"];
                    [mylastNameData addObject: @"No Invites"];
                    [myhostEMailData addObject: @"No Invites"];
                    [myhostPhoneData addObject: @"No Invites"];
                    [myGuestLocationStatusData addObject: @"No Invites"];
                    
                    [myhostAddLOne addObject: @"No Invites"];
                    [myhostAddLTwo addObject: @"No Invites"];
                    [myhostAddCity addObject: @"No Invites"];
                    [myhostAddZip addObject: @"No Invites"];
                    
                    [myInformHostData addObject: @"No Invites"];
                    
                    [myhostLatitude addObject:arr[i][@"Host Latitude"]];
                    [myhostLongitude addObject:arr[i][@"Host Longitude"]];

                    
                    [myinvitedFromData addObject: @"No Invites"];
                    [myinvitedTillData addObject: @"No Invites"];
                    
                    [myKeyData addObject:@"-1"];
                }
                
            }
            
            inviteTableIterator = i;
            
        }
        
    }];
    
    while([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0 && [myhostEMailData count]== 0 && [myhostPhoneData count]== 0 && [myGuestLocationStatusData count]== 0 && [myhostAddLOne count]== 0 && [myhostAddCity count]== 0 && [myhostAddZip count]== 0 && [myInformHostData count]== 0 && [myhostLatitude count]== 0 && [myhostLongitude count]== 0) { // Host Address line 2 is optional and hence not required here
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    // NSLog(@"Class %@",NSStringFromClass([firstNameData class]));
    
    
    for(int i =0;i<[myinvitedFromData count];i++){
        [maifirstNameData addObject:[myfirstNameData objectAtIndex:i]];
        [mailastNameData addObject:[mylastNameData objectAtIndex:i]];
        [maihostEMailData addObject:[myhostEMailData objectAtIndex:i]];
        [maihostPhoneData addObject:[myhostPhoneData objectAtIndex:i]];
        [maiGuestLocationStatusData addObject:[myGuestLocationStatusData objectAtIndex:i]];
        [maihostAddLOne addObject:[myhostAddLOne objectAtIndex:i]];
        [maihostAddLTwo addObject:[myhostAddLTwo objectAtIndex:i]];
        [maihostAddCity addObject:[myhostAddCity objectAtIndex:i]];
        [maihostAddZip addObject:[myhostAddZip objectAtIndex:i]];
        [maiinformHostData addObject:[myInformHostData objectAtIndex:i]];
        
        [maihostLatitude addObject:[myhostLatitude objectAtIndex:i]];
        [maihostLongitude addObject:[myhostLongitude objectAtIndex:i]];
        
        [maiinvitedFromData addObject:[myinvitedFromData objectAtIndex:i]];
        [maiinvitedTillData addObject:[myinvitedTillData objectAtIndex:i]];
        [maikeyData addObject:[myKeyData objectAtIndex:i]];
    }
    
    
  
    
    // Do any additional setup after loading the view from its nib.
    
        
}



-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [maifirstNameData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView registerNib:[UINib nibWithNibName:@"SimpleTableCell" bundle:nil] forCellReuseIdentifier:@"SimpleTableCell"];
    
    static NSString *cellIdentifier = @"SimpleTableCell";
    
    
    
    SimpleTableCellTableViewCell *cell = (SimpleTableCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    
    
    
    cell.firstNameLabel.text = [maifirstNameData objectAtIndex:indexPath.row];
    cell.lastNameLabel.text = [mailastNameData objectAtIndex:indexPath.row];
    cell.invitedFromDateLabel.text = [maiinvitedFromData objectAtIndex:indexPath.row];
    cell.invitedTillDateLabel.text = [maiinvitedTillData objectAtIndex:indexPath.row];
    
    //if (indexPath.row % 2 == 0)
    //{
        cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    //}
    
    //else
    //{
        
      /*
        cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"orange-1"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"orange-1"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        
        
    }

    */
    
    if([[maikeyData objectAtIndex:indexPath.row]integerValue] == -1){ // No entries in the Table
        
        
        
        
        [cell.firstNameLabel setHidden:YES];
        [cell.inviteFromLabel setHidden:YES];
        [cell.lastNameLabel setHidden:YES];
        [cell.invitedFromLabel setHidden:YES];
        [cell.invitedFromDateLabel setHidden:YES];
        [cell.invitedTillLabel setHidden:YES];
        [cell.invitedTillDateLabel setHidden:YES];
        
        
        cell.userInteractionEnabled = NO;
        self.tableView.hidden = YES;
        self.myAcceptedInvitesBack.hidden = YES;
        maiEmptyView.view.frame = self.view.bounds;
        [self.view addSubview:maiEmptyView.view];
        
        
    }
    
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    myAcceptedInviteSelcetedKey = [maikeyData objectAtIndex:indexPath.row];
    
    // Init Dest Latitude Longitude
    
   destLoc = [[CLLocation alloc] initWithLatitude:[[maihostLatitude objectAtIndex:indexPath.row] floatValue] longitude:[[maihostLongitude objectAtIndex:indexPath.row]floatValue]];
    
    mySelectedRowNumber = indexPath.row;
    
    //NSLog(@"MY SELECTED HOST Lat Long is  %@",destLoc);
    
    //NSLog(@"MY SELECTED ROW NUMBER %ld",(long)mySelectedRowNumber);
    
    if([[maiGuestLocationStatusData objectAtIndex:mySelectedRowNumber] isEqualToString:@"REACHED"]) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Looks like you have already reached this Host's Location" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
   else
   {
    
    // Show popup
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Good Job Accepting the invite!" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
    
      NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"Let's Get you going to %@'s place",[maifirstNameData objectAtIndex:indexPath.row]] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
    
    // Button 1 : Start to Host's Place
    
    CNPPopupButton *startToHostPlaceButton = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [startToHostPlaceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startToHostPlaceButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [startToHostPlaceButton setTitle:[NSString stringWithFormat:@"%@'s place!",[maifirstNameData objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
    startToHostPlaceButton.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    startToHostPlaceButton.layer.cornerRadius = 4;
    startToHostPlaceButton.selectionHandler = ^(CNPPopupButton *startToHostPlaceButton){
        
        
        [self.locationManager requestWhenInUseAuthorization];
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
           // NSLog(@"Authorized location when start to Host tapped");
            
            //[self updateDB:@"IN_TRANSIT" withInvitationStatus:@"Accepted"];
            [self startNavigation:indexPath.row];
            [self.popupController dismissPopupControllerAnimated:YES];
            
        }
        
        if (status == kCLAuthorizationStatusDenied) {
            
            //NSLog(@"Denied location when start to Host tapped");
            
            __block NSMutableString *guestAddr1 = [[NSMutableString alloc]init];
            __block NSMutableString *guestAddr2 = [[NSMutableString alloc]init];
            __block NSMutableString *guestCity = [[NSMutableString alloc]init];
            __block NSMutableString *guestZip = [[NSMutableString alloc]init];
            
            [self updateDB:@"NOT_PERMITTED" withInvitationStatus:@"Accepted" withKey:[maikeyData objectAtIndex:indexPath.row]];
            
            
            
            
            
            
            NSString *userID = [FIRAuth auth].currentUser.uid;
            [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                NSDictionary *dict = snapshot.value;
                
                
                
                
                
                
                [guestAddr1 setString:[dict valueForKey:@"Address1"]];
                [guestAddr2 setString:[dict valueForKey:@"Address2"]];
                [guestCity setString:[dict valueForKey:@"City"]];
                [guestZip setString:[dict valueForKey:@"Zip"]];
                
                
                
                
                
            }];
            while([guestAddr1 length]== 0 && [guestCity length] ==0 && [guestZip length] ==0) {
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            
           // NSLog(@"Addre1 %@",guestAddr1);
           // NSLog(@"Addre2 %@",guestAddr2);
           // NSLog(@"City %@",guestCity);
            //NSLog(@"Zip %@",guestZip);
            
            [self startNavigationWithoutLocationTracking:guestAddr1 line2:guestAddr2 city:guestCity zip:guestZip row:mySelectedRowNumber];
            [self.popupController dismissPopupControllerAnimated:YES];
            
            
            
            
        }
        
        
    };
    
    //Button 2: Decline and message
    
    // If the user wants to send a message and decline
    
    CNPPopupButton *buttonDeclineMessage = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [buttonDeclineMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buttonDeclineMessage.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [buttonDeclineMessage setTitle:@"Decline & Message" forState:UIControlStateNormal];
    buttonDeclineMessage.backgroundColor = [UIColor colorWithRed:1.0 green:0.231f blue:0.188 alpha:1.0];
    buttonDeclineMessage.layer.cornerRadius = 4;
    buttonDeclineMessage.selectionHandler = ^(CNPPopupButton *buttonDeclineMessage){
        
        
        
        // Stop Updating Location Manager if user is already in Transit
        
        [self.locationManager stopUpdatingLocation];
        
        //a.  Remove the DB entry
        
        // If Decline confirmed , ONLY then go ahead and Decline
        
        [self updateDB:@"NOT_STARTED" withInvitationStatus:@"Declined" withKey:[maikeyData objectAtIndex:indexPath.row]];

        
        // b. Send Message
        
        
        
        
        //Check for SMS and Send It
        
        if(!([[maihostPhoneData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"]))
        {
            
            
            
            
            if(![MFMessageComposeViewController canSendText]) {
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *myaction) {
                    
                    [self.popupController dismissPopupControllerAnimated:YES];
                    
                }];
                
                [ac addAction:aa];
                [self presentViewController:ac animated:YES completion:nil];
                return;
            }
            
            
            
            
            
            NSArray *recipents = [NSArray arrayWithObject:[maihostPhoneData objectAtIndex:indexPath.row]];
            
            
            NSString *message = [NSString stringWithFormat:@"Hey %@!, I am extremely sorry that something came up last minute so I might not be able to make it this time, May be next time!",[maifirstNameData objectAtIndex:indexPath.row]];
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setRecipients:recipents];
            [messageController setBody:message];
            
            
            [self presentViewController:messageController animated:YES completion:nil];
            
            
        }
        
       else  if(!([[maihostEMailData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"]))
        {
            
            //Send Email
            
            
            // Email Subject
            NSString *emailTitle = @"Message From GuestVite";
            // Email Content
            NSString *messageBody = [NSString stringWithFormat:@"Hey %@!, I am extremely sorry that something came up last minute so I might not be able to make it this time, May be next time!",[maifirstNameData objectAtIndex:indexPath.row]];
            // To address
            NSArray *toRecipents = [NSArray arrayWithObject:[maihostEMailData objectAtIndex:indexPath.row]];
            
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

    
    
    
    // Button 3: Go Back
    
    CNPPopupButton *goBackButton = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [goBackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    goBackButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [goBackButton setTitle:@"Not Now" forState:UIControlStateNormal];
    goBackButton.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    goBackButton.layer.cornerRadius = 4;
    goBackButton.selectionHandler = ^(CNPPopupButton *goBackButton){
        [self.popupController dismissPopupControllerAnimated:YES];
    };

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    UILabel *lineOneLabel = [[UILabel alloc] init];
    lineOneLabel.numberOfLines = 0;
    lineOneLabel.attributedText = lineOne;
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, lineOneLabel,startToHostPlaceButton,buttonDeclineMessage,goBackButton]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
       
   }// MAIN ELSE ENDS

    
}


-(void)startNavigation:(NSInteger)row {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Open in Maps" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* googleMaps = [UIAlertAction
                         actionWithTitle:@"Google Maps"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self openGoogleMaps:row];
                         }];
    
    UIAlertAction* appleMaps = [UIAlertAction
                                 actionWithTitle:@"Apple Maps"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self openAppleMaps:row];
                                 }];
    
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [ac dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [ac addAction:googleMaps];
    [ac addAction:appleMaps];
    [ac addAction:cancel];
    [self presentViewController:ac animated:YES completion:nil];
    
    }


-(void)openGoogleMaps:(NSInteger)row{
    // Open of Maps Part starts
    
    //Check the availability of the Google Maps app on the device
    
    if (![[UIApplication sharedApplication] canOpenURL:
          [NSURL URLWithString:@"comgooglemaps://"]]) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Your Device does not have Google Maps" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }
    
    else { // If device has Google Maps
        
        //1. Get guest's current location
        
        
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        
        [self.locationManager startUpdatingLocation];
        
        
        
        while(maicurrentLatitude == 0.0 && maicurrentLongitude == 0.0){ // Wait till latitude and longitude gets populated
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        //NSLog(@"Current Latitude is %f",maicurrentLatitude);
        //NSLog(@"Current Longitude is %f",maicurrentLongitude);
        
        
        NSString *newAddOneString = [[maihostAddLOne objectAtIndex:row] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *newAddTwoString = [[maihostAddLTwo objectAtIndex:row] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *newAddCityString = [[maihostAddCity objectAtIndex:row] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *destAddr = [[NSString alloc]init];
        
        if([[maihostAddLTwo objectAtIndex:row] length] > 0) { // If address Line 2 provided
            destAddr = [NSString stringWithFormat:@"%@,%@,%@,%@",newAddOneString,newAddTwoString,newAddCityString,[maihostAddZip objectAtIndex:row]];
        }
        
        else { // If address Line 2 NOT provided
            destAddr = [NSString stringWithFormat:@"%@,%@,%@",newAddOneString,newAddCityString,[maihostAddZip objectAtIndex:row]];
        }
        
        
        NSString *address = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%@&directionsmode=driving",maicurrentLatitude,maicurrentLongitude,destAddr];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
        
        
    }
    
    
    [self.popupController dismissPopupControllerAnimated:YES];
    
    //Open of Google Maps part Ends
    
}



-(void)openAppleMaps:(NSInteger)row{
    // Open of Maps Part starts
    
    // If device has Google Maps
        
        //1. Get guest's current location
        
        
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        
        [self.locationManager startUpdatingLocation];
        
        
        
        while(maicurrentLatitude == 0.0 && maicurrentLongitude == 0.0){ // Wait till latitude and longitude gets populated
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        //NSLog(@"Current Latitude is %f",maicurrentLatitude);
       // NSLog(@"Current Longitude is %f",maicurrentLongitude);
        
        
        NSString *newAddOneString = [[maihostAddLOne objectAtIndex:row] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *newAddTwoString = [[maihostAddLTwo objectAtIndex:row] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *newAddCityString = [[maihostAddCity objectAtIndex:row] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *destAddr = [[NSString alloc]init];
        
        if([[maihostAddLTwo objectAtIndex:row] length] > 0) { // If address Line 2 provided
            destAddr = [NSString stringWithFormat:@"%@,%@,%@,%@",newAddOneString,newAddTwoString,newAddCityString,[maihostAddZip objectAtIndex:row]];
        }
        
        else { // If address Line 2 NOT provided
            destAddr = [NSString stringWithFormat:@"%@,%@,%@",newAddOneString,newAddCityString,[maihostAddZip objectAtIndex:row]];
        }
        
        
        NSString *address = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%@",maicurrentLatitude,maicurrentLongitude,destAddr];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
        
    
    
    //Open of Apple Maps part Ends
    
}







-(void)updateDB :(NSString *)guestLocationStatus withInvitationStatus:(NSString *)guestReply withKey:(NSString *)key
{
    
    // Update DB to Accepted
    
    [[[_ref child:@"invites"] child:key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        /*
        NSString *hostaddr = [[NSString alloc]init];
        
        if([[dict valueForKey:@"Sender Address2"] length] > 0)
        {
            hostaddr = [NSString stringWithFormat:@"%@,%@,%@,%@",[dict valueForKey:@"Sender Address1"],[dict valueForKey:@"Sender Address2"],[dict valueForKey:@"Sender City"],[dict valueForKey:@"Sender Zip"]];
        }
        
        else {
            hostaddr = [NSString stringWithFormat:@"%@,%@,%@",[dict valueForKey:@"Sender Address1"],[dict valueForKey:@"Sender City"],[dict valueForKey:@"Sender Zip"]];
        }
        
        CLLocationCoordinate2D dest = [self geoCodeUsingAddress:hostaddr];
        */
        
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
                                   @"Host Latitude": [dict valueForKey:@"Host Latitude"],
                                   @"Host Longitude": [dict valueForKey:@"Host Longitude"],
                                   @"Guest Location Status" : guestLocationStatus,
                                   @"Host Send Messages" : [dict valueForKey:@"Host Send Messages"],
                                   };//Dict post
        
        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", key]: postDict};
        [_ref updateChildValues:childUpdates];
        
       
        
        
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



// Notification

- (void) createANotification {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = nil;
    
    localNotif.alertTitle = @"GuestVite";
    localNotif.alertBody = @"You have almost reached your Host's location , Your location tracking will now be stopped";
    localNotif.alertAction = @"OK";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    localNotif.applicationIconBadgeNumber = 1;
    
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    
    
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:[NSString stringWithFormat:@"Sorry, Encountered the following error occured \n\n %@",error] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [ac addAction:aa];
    [self presentViewController:ac animated:YES completion:nil];
}




-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    
    
    
    
    maicurrentLatitude = locations.lastObject.coordinate.latitude;
    maicurrentLongitude = locations.lastObject.coordinate.longitude;
    
   
    /*
    NSString *hostaddr = [NSString stringWithFormat:@"%@,%@,%@,%@",[maihostAddLOne objectAtIndex:mySelectedRowNumber],[maihostAddLTwo objectAtIndex:mySelectedRowNumber],[maihostAddCity objectAtIndex:mySelectedRowNumber],[maihostAddZip objectAtIndex:mySelectedRowNumber]];
    
    NSLog(@"Host Address is %@",hostaddr);
    CLLocationCoordinate2D dest = [self geoCodeUsingAddress:hostaddr];
    */
    
    
    
    
 
    
  
    //NSLog(@"DEST LOC is %@",destLoc);
    
    
    
    
    // UPDATE DB WITH latitude, longuitude and ACCEPTED ENDS
    
    // IF the GUEST AND HOST DISTANCE < 0.2 MILE  THE STOP UPDATING LOCATION AND BREAK THE FUNCTION
    
    if([locations.lastObject distanceFromLocation:destLoc]*0.000621371 < 0.2){
        
        [self.locationManager stopUpdatingLocation];
        
        
        // DB Updates to REACHED
        
        [[[_ref child:@"invites"] child:[maikeyData objectAtIndex:mySelectedRowNumber]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
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
                                       @"Guest Latitude": [NSNumber numberWithFloat:maicurrentLatitude],
                                       @"Guest Longitude": [NSNumber numberWithFloat:maicurrentLongitude],
                                       @"Host Latitude": [dict valueForKey:@"Host Latitude"],
                                       @"Host Longitude": [dict valueForKey:@"Host Longitude"],
                                       @"Guest Location Status" : @"REACHED",
                                       @"Host Send Messages" : [dict valueForKey:@"Host Send Messages"],
                                       };//Dict post
            
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", [maikeyData objectAtIndex:mySelectedRowNumber]]: postDict};
            [_ref updateChildValues:childUpdates];
            
        }];
        
        // NSLog(@"GUEST REACHED");
        
        //Fire Notification
        [self createANotification];
    }
    
    
    else
    {
        
        // DB Updates if distance more than 0.1 mile
        
        [[[_ref child:@"invites"] child:[maikeyData objectAtIndex:mySelectedRowNumber]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
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
                                       @"Guest Latitude": [NSNumber numberWithFloat:maicurrentLatitude],
                                       @"Guest Longitude": [NSNumber numberWithFloat:maicurrentLongitude],
                                       @"Host Latitude": [dict valueForKey:@"Host Latitude"],
                                       @"Host Longitude": [dict valueForKey:@"Host Longitude"],
                                       @"Guest Location Status" : @"IN_TRANSIT",
                                       @"Host Send Messages" : [dict valueForKey:@"Host Send Messages"],
                                       };//Dict post
            
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", [maikeyData objectAtIndex:mySelectedRowNumber]]: postDict};
            [_ref updateChildValues:childUpdates];
        }];
        
    }
    
    
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
            break;
            
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
        case MFMailComposeResultSent:
                        break;

        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)startNavigationWithoutLocationTracking :(NSString *)guestAddressLine1 line2:(NSString *)guestAddressLine2 city:(NSString *)guestAddressCity zip:(NSString *)guestAddressZip row:(NSInteger)selectedRow{
    
    
    // Open of Maps Part starts
    
    //Check the availability of the Google Maps app on the device
    
    if (![[UIApplication sharedApplication] canOpenURL:
          [NSURL URLWithString:@"comgooglemaps://"]]) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Sorry, Your Device does not have Google Maps" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    else { // If device has Google Maps
        
        
        // Getting GUEST Address
        NSString *newAddOneGuestString = [ guestAddressLine1 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *newAddTwoGuestString = [ guestAddressLine2 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *newAddCityGuestString = [ guestAddressCity stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *sourceAddr = [[NSString alloc]init];
        
        if([guestAddressLine2 length] > 0) { // If address Line 2 provided
            sourceAddr = [NSString stringWithFormat:@"%@,%@,%@,%@",newAddOneGuestString,newAddTwoGuestString,newAddCityGuestString,guestAddressZip];
        }
        
        else { // If address Line 2 NOT provided
            sourceAddr = [NSString stringWithFormat:@"%@,%@,%@",newAddOneGuestString,newAddCityGuestString,guestAddressZip];
        }
        
        
        
        
        // Getting HOST Address
        NSString *newAddOneHostString = [[maihostAddLOne objectAtIndex:selectedRow] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *newAddTwoHostString = [[maihostAddLTwo objectAtIndex:selectedRow] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *newAddCityHostString = [[maihostAddCity objectAtIndex:selectedRow] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *destAddr = [[NSString alloc]init];
        
        if([[maihostAddLTwo objectAtIndex:selectedRow] length] > 0) { // If address Line 2 provided
            destAddr = [NSString stringWithFormat:@"%@,%@,%@,%@",newAddOneHostString,newAddTwoHostString,newAddCityHostString,[maihostAddZip objectAtIndex:selectedRow]];
        }
        
        else { // If address Line 2 NOT provided
            destAddr = [NSString stringWithFormat:@"%@,%@,%@",newAddOneHostString,newAddCityHostString,[maihostAddZip objectAtIndex:selectedRow]];
        }
        
        
        NSString *address = [NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=driving",sourceAddr,destAddr];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
        
        
    }
    
    
    [self.popupController dismissPopupControllerAnimated:YES];
    
    
    //Open of Maps part Ends
    
    
    
}



@end
