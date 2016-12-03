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
#import "HomePageViewController.h"
#import "EmptyViewController.h"

@import Firebase;


@interface AwaitMyResponseViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UINavigationBar *awaitMyResponseBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;


@property (nonatomic, strong) CNPPopupController *popupController;
@end

@implementation AwaitMyResponseViewController


EmptyViewController *amrEmptyView;
NSMutableArray *firstNameData;
NSMutableArray *lastNameData;
NSMutableArray *hostEMailData;
NSMutableArray *hostPhoneData;

NSMutableArray *hostAddLOne;
NSMutableArray *hostAddLTwo;
NSMutableArray *hostAddCity;
NSMutableArray *hostAddZip;

NSMutableArray *guestFirstNameData;
NSMutableArray *informHostData;

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
    // Do any additional setup after loading the view from its nib.
    [self setNeedsStatusBarAppearanceUpdate];
    
    
    amrEmptyView = [[EmptyViewController alloc]init];
    firstNameData = [[NSMutableArray alloc]init];
    lastNameData = [[NSMutableArray alloc]init];
    hostEMailData = [[NSMutableArray alloc]init];
    hostPhoneData = [[NSMutableArray alloc]init];
    
    hostAddLOne = [[NSMutableArray alloc]init];
    hostAddLTwo = [[NSMutableArray alloc]init];
    hostAddCity = [[NSMutableArray alloc]init];
    hostAddZip = [[NSMutableArray alloc]init];
    
    guestFirstNameData = [[NSMutableArray alloc]init];
    informHostData = [[NSMutableArray alloc]init];
    
    invitedFromData = [[NSMutableArray alloc]init];
    invitedTillData = [[NSMutableArray alloc]init];
    personalMessageData = [[NSMutableArray alloc]init];
    keyData = [[NSMutableArray alloc]init];
    
    
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    
    
    
    
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
    
    
    __block NSMutableArray *myInformHostData = [[NSMutableArray alloc] init];
    
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
        
        currentUserEMail =  [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"EMail"]];
        currentUserPhone  = [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"Phone"]];
        
        
    }];
    while([currentUserEMail length]== 0 || [currentUserPhone length] ==0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    
    
    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        
        NSString *endDateTime = [[NSString alloc] init];
        NSArray * arr = [dict allValues];
        keys = [dict allKeys];
        
        
        inviteTableLength = [arr count];
        
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            
            
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
                
                [myInformHostData addObject:arr[i][@"Host Send Messages"]];
                
                
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
                
                [myInformHostData addObject:arr[i][@"Host Send Messages"]];
                
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
                    
                    [myInformHostData addObject: @"No Invites"];
                    
                    [myinvitedFromData addObject: @"No Invites"];
                    [myinvitedTillData addObject: @"No Invites"];
                    [myPersonalMessageData addObject: @"No Invites"];
                    [myKeyData addObject:@"-1"];
                }
                
            }
            
            inviteTableIterator = i;
            
        }
        
    }];
    
    while([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0 && [myhostEMailData count]== 0 && [myhostPhoneData count]== 0  && [myhostAddLOne count]== 0 && [myhostAddCity count]== 0 && [myhostAddZip count]== 0 && [myInformHostData count]== 0) { // Host Address line 2 is optional and hence not required here
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
        
        [informHostData addObject:[myInformHostData objectAtIndex:i]];
        
        [invitedFromData addObject:[myinvitedFromData objectAtIndex:i]];
        [invitedTillData addObject:[myinvitedTillData objectAtIndex:i]];
        [personalMessageData addObject:[myPersonalMessageData objectAtIndex:i]];
        [keyData addObject:[myKeyData objectAtIndex:i]];
    }
    
    
    //NSLog(@"INSIDE AWAIT MY RESPONSE Key data is %@",keyData);
    
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
    
    return [firstNameData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView registerNib:[UINib nibWithNibName:@"SimpleTableCell" bundle:nil] forCellReuseIdentifier:@"SimpleTableCell"];
    
    static NSString *cellIdentifier = @"SimpleTableCell";
    
    
    
    SimpleTableCellTableViewCell *cell = (SimpleTableCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    
    
    
    cell.firstNameLabel.text = [firstNameData objectAtIndex:indexPath.row];
    cell.lastNameLabel.text = [lastNameData objectAtIndex:indexPath.row];
    cell.invitedFromDateLabel.text = [invitedFromData objectAtIndex:indexPath.row];
    cell.invitedTillDateLabel.text = [invitedTillData objectAtIndex:indexPath.row];
    
    
    //if (indexPath.row % 2 == 0)
    //{
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    //}
    
    // else
    //{
    
    /*
     cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"orange-1"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
     cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"orange-1"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
     
     }
     */
    
    if([[keyData objectAtIndex:indexPath.row]integerValue] == -1){ // No entries in the Table
        
        [cell.firstNameLabel setHidden:YES];
        [cell.lastNameLabel setHidden:YES];
        [cell.invitedFromDateLabel setHidden:YES];
        [cell.invitedTillDateLabel setHidden:YES];
        [cell.inviteFromLabel setHidden:YES];
        [cell.invitedFromLabel setHidden:YES];
        [cell.invitedTillLabel setHidden:YES];
        
        
        cell.userInteractionEnabled = NO;
        self.tableView.hidden = YES;
        self.awaitMyResponseBack.hidden = YES;
        amrEmptyView.view.frame = self.view.bounds;
        [self.view addSubview:amrEmptyView.view];
    }
    
    
    
    
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
    
    amrCellTapped.informHost = [informHostData objectAtIndex:indexPath.row];
    
    amrCellTapped.invitedOn = [invitedFromData objectAtIndex:indexPath.row];
    amrCellTapped.invitedTill = [invitedTillData objectAtIndex:indexPath.row];
    amrCellTapped.personalMessage = [personalMessageData objectAtIndex:indexPath.row];
    amrCellTapped.key = [keyData objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:amrCellTapped animated:YES];
    
    [self presentViewController:amrCellTapped animated:YES completion:nil];
    
}





@end