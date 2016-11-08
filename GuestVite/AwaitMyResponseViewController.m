//
//  AwaitMyResponseViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-24.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AwaitMyResponseViewController.h"
#import "SimpleTableCellTableViewCell.h"
#import "AMRCellTapped.h"
#import "SendNewInviteViewController.h"
#import "CNPPopupController.h"
#import <MessageUI/MessageUI.h>

@import Firebase;


@interface AwaitMyResponseViewController () <UITableViewDelegate, UITableViewDataSource,SWTableViewCellDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UINavigationBar *awaitMyResponseBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;

@property (nonatomic, strong) CNPPopupController *popupController;
@end

@implementation AwaitMyResponseViewController


 NSMutableArray *firstNameData;
 NSMutableArray *lastNameData;
 NSMutableArray *hostEMailData;
 NSMutableArray *hostPhoneData;

 NSMutableArray *hostAddLOne;
 NSMutableArray *hostAddLTwo;
 NSMutableArray *hostAddCity;
 NSMutableArray *hostAddZip;



 NSMutableArray *nameData;
 NSMutableArray *invitedFromData;
 NSMutableArray *invitedTillData;
 NSMutableArray *personalMessageData;
 NSMutableArray *keyData;

NSArray *keys;

-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
   
    [dateFormatter setTimeZone:timeZone];
    return [dateFormatter dateFromString:dateStr];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    firstNameData = [[NSMutableArray alloc]init];
    lastNameData = [[NSMutableArray alloc]init];
    hostEMailData = [[NSMutableArray alloc]init];
    hostPhoneData = [[NSMutableArray alloc]init];
    
    hostAddLOne = [[NSMutableArray alloc]init];
    hostAddLTwo = [[NSMutableArray alloc]init];
    hostAddCity = [[NSMutableArray alloc]init];
    hostAddZip = [[NSMutableArray alloc]init];
    
    
    
    invitedFromData = [[NSMutableArray alloc]init];
    invitedTillData = [[NSMutableArray alloc]init];
    personalMessageData = [[NSMutableArray alloc]init];
    keyData = [[NSMutableArray alloc]init];
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Black_BG"]];
    self.tableView.backgroundColor = background;
    
    
    self.awaitMyResponseBack = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 400, 64)];
    
    [self.awaitMyResponseBack setFrame:CGRectMake(0, 0, 400, 64)];
    
    self.awaitMyResponseBack.translucent = YES;
    
    
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
    
    [self.view addSubview:_awaitMyResponseBack];
    
    keys = [[NSArray alloc]init];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    //NSLog(@"DATE IS %@",[NSDate date]);
    
    
    NSDate *loginDate = [self dateToFormatedDate:[dateFormatter stringFromDate:[NSDate date]]];
    
    
    __block NSMutableArray *myfirstNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *mylastNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostEMailData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostPhoneData = [[NSMutableArray alloc] init];
    
    
    __block NSMutableArray *myhostAddLOne = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostAddLTwo = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostAddCity = [[NSMutableArray alloc] init];
    __block NSMutableArray *myhostAddZip = [[NSMutableArray alloc] init];
    
    
    __block NSMutableArray *myinvitedFromData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedTillData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myPersonalMessageData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myKeyData = [[NSMutableArray alloc] init];
   
    
    __block NSString *currentUserEMail = [[NSString alloc] init];
    __block NSString *currentUserPhone = [[NSString alloc] init];
    
    __block NSUInteger inviteTableIterator;
    
    __block NSUInteger inviteTableLength;
    
    self.ref = [[FIRDatabase database] reference];
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dictUser = snapshot.value;
         NSArray * arrUser = [dictUser allValues];
        //NSLog(@"ARR USER %@",arrUser);
        
        currentUserEMail =  [NSString stringWithFormat:@"%@",arrUser[0]];
        currentUserPhone  = [NSString stringWithFormat:@"%@",arrUser[3]];
        
       
    }];
    while([currentUserEMail length]== 0 || [currentUserPhone length] ==0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
   // NSLog(@"Current User Email %@",currentUserEMail);
   // NSLog(@"Current User Phone %@",currentUserPhone);


    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        //NSString *startDateTime  = [[NSString alloc] init];
        NSString *endDateTime = [[NSString alloc] init];
        NSArray * arr = [dict allValues];
        keys = [dict allKeys];
        //NSLog(@"Array %@",arr[0][@"Sender First Name"]);
        
       // NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        //NSLog(@"ARR count %lu",(unsigned long)[arr count]);
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            
            //NSLog(@"PESONAl MESSAGE at iteattion %d IS %@",i,arr[i][@"Mesage From Sender"]);
                
            if([currentUserEMail length] > 0 && [arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && ([arr[i][@"Receiver EMail"] isEqualToString:currentUserEMail])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending))
            {
                
                //NSLog(@"INSIDE EMAIL");
            
                [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                [mylastNameData addObject:arr[i][@"Sender Last Name"]];
                [myhostEMailData addObject:arr[i][@"Sender EMail"]];
                [myhostPhoneData addObject:arr[i][@"Sender Phone"]];
                
                [myhostAddLOne addObject: arr[i][@"Sender Address1"]];
                [myhostAddLTwo addObject:arr[i][@"Sender Address2"]];
                [myhostAddCity addObject:arr[i][@"Sender City"]];
                [myhostAddZip addObject:arr[i][@"Sender Zip"]];

                
                
                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [myPersonalMessageData addObject:arr[i][@"Mesage From Sender"]];
                [myKeyData addObject:keys[i]];
                continue;
                
            }
            
            
                
                if([currentUserPhone length] > 0 && [arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && ([arr[i][@"Receiver Phone"] isEqualToString:currentUserPhone])
                   && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending))
                {
                    
                    [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                    [mylastNameData addObject:arr[i][@"Sender Last Name"]];
                    [myhostEMailData addObject:arr[i][@"Sender EMail"]];
                    [myhostPhoneData addObject:arr[i][@"Sender Phone"]];
                    
                    
                    [myhostAddLOne addObject: arr[i][@"Sender Address1"]];
                    [myhostAddLTwo addObject:arr[i][@"Sender Address2"]];
                    [myhostAddCity addObject:arr[i][@"Sender City"]];
                    [myhostAddZip addObject:arr[i][@"Sender Zip"]];
                    
                    
                    [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                    [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                    [myPersonalMessageData addObject:arr[i][@"Mesage From Sender"]];
                    [myKeyData addObject:keys[i]];
                    
                    continue;
                    
                }
                
                
                
                
            
            if(i == ([arr count]-1)){ // Check in case of last iteration and Add "No Invites" Only if no data is added to invites list
                
                
                    //NSLog(@"Last Iteration");
                if([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0)
                {
                    [myfirstNameData addObject: @"No Invites"];
                    [mylastNameData addObject: @"No Invites"];
                    [myhostEMailData addObject: @"No Invites"];
                    [myhostPhoneData addObject: @"No Invites"];
                    
                    [myhostAddLOne addObject: @"No Invites"];
                    [myhostAddLTwo addObject: @"No Invites"];
                    [myhostAddCity addObject: @"No Invites"];
                    [myhostAddZip addObject: @"No Invites"];
                    
                    
                    
                    [myinvitedFromData addObject: @"No Invites"];
                    [myinvitedTillData addObject: @"No Invites"];
                    [myPersonalMessageData addObject: @"No Invites"];
                    [myKeyData addObject:@"-1"];
                }
                
            }
            
            inviteTableIterator = i;
            
        }
        
    }];
    
    while([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0 && [myhostEMailData count]== 0 && [myhostPhoneData count]== 0  && [myhostAddLOne count]== 0 && [myhostAddCity count]== 0 && [myhostAddZip count]== 0) { // Host Address line 2 is optional and hence not required here
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
   
   // NSLog(@"Class %@",NSStringFromClass([firstNameData class]));
    
    
    for(int i =0;i<[myinvitedFromData count];i++){
        [firstNameData addObject:[myfirstNameData objectAtIndex:i]];
        [lastNameData addObject:[mylastNameData objectAtIndex:i]];
        [hostEMailData addObject:[myhostEMailData objectAtIndex:i]];
        [hostPhoneData addObject:[myhostPhoneData objectAtIndex:i]];
        
        [hostAddLOne addObject:[myhostAddLOne objectAtIndex:i]];
        [hostAddLTwo addObject:[myhostAddLTwo objectAtIndex:i]];
        [hostAddCity addObject:[myhostAddCity objectAtIndex:i]];
        [hostAddZip addObject:[myhostAddZip objectAtIndex:i]];
        
        
        [invitedFromData addObject:[myinvitedFromData objectAtIndex:i]];
        [invitedTillData addObject:[myinvitedTillData objectAtIndex:i]];
        [personalMessageData addObject:[myPersonalMessageData objectAtIndex:i]];
        [keyData addObject:[myKeyData objectAtIndex:i]];
    }

   
   // NSLog(@"Key data is %@",keyData);
    
    // Do any additional setup after loading the view from its nib.
    
    
   
}


- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [firstNameData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView registerNib:[UINib nibWithNibName:@"SimpleTableCell" bundle:nil] forCellReuseIdentifier:@"SimpleTableCell"];
    
    static NSString *cellIdentifier = @"SimpleTableCell";
    
    
    
    SimpleTableCellTableViewCell *cell = (SimpleTableCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Add utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Accept"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Decline"];
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    
    
    
    cell.firstNameLabel.text = [firstNameData objectAtIndex:indexPath.row];
    cell.lastNameLabel.text = [lastNameData objectAtIndex:indexPath.row];
    cell.invitedFromDateLabel.text = [invitedFromData objectAtIndex:indexPath.row];
    cell.invitedTillDateLabel.text = [invitedTillData objectAtIndex:indexPath.row];
    
    if([[keyData objectAtIndex:indexPath.row]integerValue] == -1){ // No entries in the Table
        
        
        
        cell.inviteFromLabel.text = @"No Invitations are awaiting your response";
        
        
        [cell.firstNameLabel setHidden:YES];
        
        [cell.lastNameLabel setHidden:YES];
        [cell.invitedFromLabel setHidden:YES];
        [cell.invitedFromDateLabel setHidden:YES];
        [cell.invitedTillLabel setHidden:YES];
        [cell.invitedTillDateLabel setHidden:YES];
        
        
        cell.userInteractionEnabled = NO;
        self.tableView.hidden = YES;
        
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Black_BG"]];
        
        self.view.backgroundColor = background;
        
        CGRect labelFrame = CGRectMake( 10, 200, 500, 30 );
        UILabel* label = [[UILabel alloc] initWithFrame: labelFrame];
        [label setText: @"No Invitations are awaiting your response"];
        [label setTextColor: [UIColor orangeColor]];
        [self.view addSubview: label];
        
        CGRect labelFrame1 = CGRectMake( 10, 250, 500, 30 );
        UILabel* label1 = [[UILabel alloc] initWithFrame: labelFrame1];
        [label1 setText: @"Want to Invite SomeOne?, Send Invite Now!"];
        [label1 setTextColor: [UIColor orangeColor]];
        [self.view addSubview: label1];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"Send new Invite" forState:UIControlStateNormal];
        [button sizeToFit];
        button.center = CGPointMake(320/2, 300);
        
        [button addTarget:self action:@selector(buttonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"Black_BG"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"Black_BG"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    

    
    return cell;
}

- (void)buttonPressed:(UIButton *)button {
    SendNewInviteViewController *sendNewVC =
    [[SendNewInviteViewController alloc] initWithNibName:@"SendNewInviteViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:sendNewVC animated:YES];
    
    [self presentViewController:sendNewVC animated:YES completion:nil];
}

            

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    
    AMRCellTapped *amrCellTapped =
    [[AMRCellTapped alloc] initWithNibName:@"AMRCellTapped" bundle:nil];
    
    amrCellTapped.inviteByFirstName = [firstNameData objectAtIndex:indexPath.row];
    amrCellTapped.inviteByLastName = [lastNameData objectAtIndex:indexPath.row];
    amrCellTapped.hostEMail = [hostEMailData objectAtIndex:indexPath.row];
    amrCellTapped.hostPhone = [hostPhoneData objectAtIndex:indexPath.row];
    
    amrCellTapped.hostAddrLineOne = [hostAddLOne objectAtIndex:indexPath.row];
    amrCellTapped.hostAddrLineTwo = [hostAddLTwo objectAtIndex:indexPath.row];
    amrCellTapped.hostAddrCity = [hostAddCity objectAtIndex:indexPath.row];
    amrCellTapped.hostAddrZip = [hostAddZip objectAtIndex:indexPath.row];
    
    
    amrCellTapped.invitedOn = [invitedFromData objectAtIndex:indexPath.row];
    amrCellTapped.invitedTill = [invitedTillData objectAtIndex:indexPath.row];
    amrCellTapped.personalMessage = [personalMessageData objectAtIndex:indexPath.row];
    amrCellTapped.key = [keyData objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:amrCellTapped animated:YES];
    
    [self presentViewController:amrCellTapped animated:YES completion:nil];
    
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
        {
            
            
            // Case of Invite accepted - Update the status to ACCEPTED
             NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                NSDictionary *dict = snapshot.value;
                //keys = [dict allKeys];
                NSArray * arr = [dict allValues];
                
               // NSLog(@"INVITED FROM DATA %@",invitedFromData);
                
                for(int i=0;i<[arr count];i++){
                    
                    
                    if([arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && [[invitedFromData objectAtIndex:cellIndexPath.row] isEqualToString:arr[i][@"Invite For Date"]])
                       
                    {
                        
                       
                        
                      //  NSLog(@"ARR INVITE FOR DATE %@",arr[i][@"Invite For Date"]);
                        
                        [firstNameData removeObjectAtIndex:cellIndexPath.row];
                        [lastNameData removeObjectAtIndex:cellIndexPath.row];
                        [hostEMailData removeObjectAtIndex:cellIndexPath.row];
                        [hostPhoneData removeObjectAtIndex:cellIndexPath.row];
                        [invitedFromData removeObjectAtIndex:cellIndexPath.row];
                        [invitedTillData removeObjectAtIndex:cellIndexPath.row];
                        [personalMessageData removeObjectAtIndex:cellIndexPath.row];
                        [keyData removeObjectAtIndex:cellIndexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                        
                        
                        //Update the data Model : Firebase in this case
                        
                        [self.tableView reloadData];
                        
                      //   NSLog(@"KEYS AT INDEX!! %@",keys[i]);
                        
                    arr[i][@"Invitation Status"] = @"Accepted";
                      //  NSLog(@"Status Changed %@", arr[i][@"Invitation Status"]);
                        
                        NSDictionary *postDict = @{@"Sender First Name": arr[i][@"Sender First Name"],
                                                   @"Sender Last Name": arr[i][@"Sender Last Name"],
                                                   @"Sender EMail": arr[i][@"Sender EMail"],
                                                   @"Sender Address1": arr[i][@"Sender Address1"],
                                                   @"Sender Address2": arr[i][@"Sender Address2"],
                                                   @"Sender City": arr[i][@"Sender City"],
                                                   @"Sender Zip": arr[i][@"Sender Zip"],
                                                   @"Sender Phone": arr[i][@"Sender Phone"],
                                                   @"Mesage From Sender": arr[i][@"Mesage From Sender"],
                                                   @"Receiver First Name": arr[i][@"Receiver First Name"],
                                                   @"Receiver Last Name": arr[i][@"Receiver Last Name"],
                                                   @"Receiver EMail": arr[i][@"Receiver EMail"],
                                                   @"Receiver Phone": arr[i][@"Receiver Phone"],
                                                   @"Invite For Date": arr[i][@"Invite For Date"],
                                                   @"Invite Valid Till Date": arr[i][@"Invite Valid Till Date"],
                                                   @"Invitation Status": arr[i][@"Invitation Status"],
                                                   };//Dict post
                       // NSLog(@"POST DIC %@",postDict);
                        
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", keys[i]]: postDict};
                        [_ref updateChildValues:childUpdates];
                        break; // When the row is deleted - No need to go through other iterations
                    }

                }
            }];
            
            
            
            
            
            break;
        }
        case 1:
        {
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
                
                NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                
               // NSLog(@"HOST EMAIL %@",[hostEMailData objectAtIndex:cellIndexPath.row]);
              //  NSLog(@"HOST PHONE %@",[hostPhoneData objectAtIndex:cellIndexPath.row]);
                
                
                                // a. Send Message
                
                    
                     //Check for SMS and Send It
                    
                    if(!([[hostPhoneData objectAtIndex:cellIndexPath.row] isEqualToString:@"Not Specified"]))
                    {
                        
                        
                       
                        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                        
                        if(![MFMessageComposeViewController canSendText]) {
                            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                            
                            [ac addAction:aa];
                            [self presentViewController:ac animated:YES completion:nil];
                            return;
                        }
                        
                        
                        
                        
                        
                        NSArray *recipents = [NSArray arrayWithObject:[hostPhoneData objectAtIndex:cellIndexPath.row]];
                        
                        
                        NSString *message = [NSString stringWithFormat:@"Hey %@!, I am extremely sorry that I would not be able to make it this time , May be next time!",[firstNameData objectAtIndex:cellIndexPath.row]];
                        
                        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                        messageController.messageComposeDelegate = self;
                        [messageController setRecipients:recipents];
                        [messageController setBody:message];
                        
                        
                        [self presentViewController:messageController animated:YES completion:nil];
                        
                        
                    }

                    
                    //Send Email
                
                
                if(!([[hostEMailData objectAtIndex:cellIndexPath.row] isEqualToString:@"Not Specified"]))
                {

                    
                    // Email Subject
                    NSString *emailTitle = @"Message From GeuestVite";
                    // Email Content
                    NSString *messageBody = [NSString stringWithFormat:@"Hey %@!, I am extremely sorry that I would not be able to make it this time , May be next time!",[firstNameData objectAtIndex:cellIndexPath.row]];
                    // To address
                    NSArray *toRecipents = [NSArray arrayWithObject:[hostEMailData objectAtIndex:cellIndexPath.row]];
                    
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
                
               
                
                [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    
                    NSDictionary *dict = snapshot.value;
                    NSArray *keys = [dict allKeys];
                    NSArray * arr = [dict allValues];
                    
                    
                    
                    for(int i=0;i<[arr count];i++){
                        
                      //  NSLog(@"CELL INDEX %ld",cellIndexPath.row);
                        
                        
                        if([arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && [[invitedFromData objectAtIndex:cellIndexPath.row] isEqualToString:arr[i][@"Invite For Date"]])
                        { // If status is pending  and From date in table matches the one from the table
                            
                            
                            [firstNameData removeObjectAtIndex:cellIndexPath.row];
                            [lastNameData removeObjectAtIndex:cellIndexPath.row];
                            [hostEMailData removeObjectAtIndex:cellIndexPath.row];
                            [hostPhoneData removeObjectAtIndex:cellIndexPath.row];
                            [invitedFromData removeObjectAtIndex:cellIndexPath.row];
                            [invitedTillData removeObjectAtIndex:cellIndexPath.row];
                            [personalMessageData removeObjectAtIndex:cellIndexPath.row];
                            [keyData removeObjectAtIndex:cellIndexPath.row];
                            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                            [self.tableView reloadData];
                            
                            
                            //Update the data Model : Firebase in this case
                         //   NSLog(@"KEYS AT INDEX!! %@",keys[i]);
                            
                            arr[i][@"Invitation Status"] = @"Declined";
                         //   NSLog(@"Status Changed %@", arr[i][@"Invitation Status"]);
                            
                            NSDictionary *postDict = @{@"Sender First Name": arr[i][@"Sender First Name"],
                                                       @"Sender Last Name": arr[i][@"Sender Last Name"],
                                                       @"Sender EMail": arr[i][@"Sender EMail"],
                                                       @"Sender Address1": arr[i][@"Sender Address1"],
                                                       @"Sender Address2": arr[i][@"Sender Address2"],
                                                       @"Sender City": arr[i][@"Sender City"],
                                                       @"Sender Zip": arr[i][@"Sender Zip"],
                                                       @"Sender Phone": arr[i][@"Sender Phone"],
                                                       @"Mesage From Sender": arr[i][@"Mesage From Sender"],
                                                       @"Receiver First Name": arr[i][@"Receiver First Name"],
                                                       @"Receiver Last Name": arr[i][@"Receiver Last Name"],
                                                       @"Receiver EMail": arr[i][@"Receiver EMail"],
                                                       @"Receiver Phone": arr[i][@"Receiver Phone"],
                                                       @"Invite For Date": arr[i][@"Invite For Date"],
                                                       @"Invite Valid Till Date": arr[i][@"Invite Valid Till Date"],
                                                       @"Invitation Status": arr[i][@"Invitation Status"],
                                                       };//Dict post
                        //    NSLog(@"POST DIC %@",postDict);
                            
                            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", keys[i]]: postDict};
                            [_ref updateChildValues:childUpdates];
                            
                            break; // When the row is deleted - No need to go through other iterations
                        }
                        
                    }
                }];
                

                
                
                
                
                
                
                [self.popupController dismissPopupControllerAnimated:YES];
               // NSLog(@"Block for button: %@", buttonYesMessage.titleLabel.text);
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
                
                 NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                 
                 [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                 
                 NSDictionary *dict = snapshot.value;
                 NSArray *keys = [dict allKeys];
                 NSArray * arr = [dict allValues];
                 
                 
                 
                 for(int i=0;i<[arr count];i++){
                 
                // NSLog(@"CELL INDEX %ld",cellIndexPath.row);
                 
                 
                 if([arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && [[invitedFromData objectAtIndex:cellIndexPath.row] isEqualToString:arr[i][@"Invite For Date"]])
                 { // If status is pending  and From date in table matches the one from the table
                 
                 
                 [firstNameData removeObjectAtIndex:cellIndexPath.row];
                 [lastNameData removeObjectAtIndex:cellIndexPath.row];
                 [hostEMailData removeObjectAtIndex:cellIndexPath.row];
                 [hostPhoneData removeObjectAtIndex:cellIndexPath.row];
                 [invitedFromData removeObjectAtIndex:cellIndexPath.row];
                 [invitedTillData removeObjectAtIndex:cellIndexPath.row];
                 [personalMessageData removeObjectAtIndex:cellIndexPath.row];
                 [keyData removeObjectAtIndex:cellIndexPath.row];
                 [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                 withRowAnimation:UITableViewRowAnimationAutomatic];
                 [self.tableView reloadData];
                 
                 
                 //Update the data Model : Firebase in this case
               //  NSLog(@"KEYS AT INDEX!! %@",keys[i]);
                 
                 arr[i][@"Invitation Status"] = @"Declined";
                // NSLog(@"Status Changed %@", arr[i][@"Invitation Status"]);
                 
                 NSDictionary *postDict = @{@"Sender First Name": arr[i][@"Sender First Name"],
                 @"Sender Last Name": arr[i][@"Sender Last Name"],
                 @"Sender EMail": arr[i][@"Sender EMail"],
                 @"Sender Address1": arr[i][@"Sender Address1"],
                 @"Sender Address2": arr[i][@"Sender Address2"],
                 @"Sender City": arr[i][@"Sender City"],
                 @"Sender Zip": arr[i][@"Sender Zip"],
                 @"Sender Phone": arr[i][@"Sender Phone"],
                 @"Mesage From Sender": arr[i][@"Mesage From Sender"],
                 @"Receiver First Name": arr[i][@"Receiver First Name"],
                 @"Receiver Last Name": arr[i][@"Receiver Last Name"],
                 @"Receiver EMail": arr[i][@"Receiver EMail"],
                 @"Receiver Phone": arr[i][@"Receiver Phone"],
                 @"Invite For Date": arr[i][@"Invite For Date"],
                 @"Invite Valid Till Date": arr[i][@"Invite Valid Till Date"],
                 @"Invitation Status": arr[i][@"Invitation Status"],
                 };//Dict post
              //   NSLog(@"POST DIC %@",postDict);
                 
                 NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", keys[i]]: postDict};
                 [_ref updateChildValues:childUpdates];
                 
                 break; // When the row is deleted - No need to go through other iterations
                 }
                 
                 }
                 }];

                
                
                [self.popupController dismissPopupControllerAnimated:YES];
               // NSLog(@"Block for button: %@", buttonYes.titleLabel.text);
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
              //  NSLog(@"Block for button: %@", buttonNoMessage.titleLabel.text);
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

            
            
            
            
                        break;
        }
        default:
            break;
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
        case MFMailComposeResultSent: {
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
