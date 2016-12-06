//
//  PrevInvSentViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-30.
//  Copyright © 2016 admin. All rights reserved.
//

#import "PrevInvSentViewController.h"
#import "PrevInvSentCell.h"
#import "EmptyViewController.h"

@import Firebase;

@interface PrevInvSentViewController () <UITableViewDelegate, UITableViewDataSource,SWTableViewCellDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *prevInvSentBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;


@end

@implementation PrevInvSentViewController

EmptyViewController *pisEmptyView;
NSMutableArray *pisGuestEMailData;
NSMutableArray *pisGuestPhoneData;
NSMutableArray *pisnameData;
NSMutableArray *pisinvitedFromData;
NSMutableArray *pisinvitedTillData;
NSMutableArray *pisactionTakenData;

NSMutableArray *piskeyData;

NSArray *piskeys;

UIActivityIndicatorView *activityIndicator;

-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [dateFormatter setTimeZone:timeZone];
    return [dateFormatter dateFromString:dateStr];
}


-(void) viewWillAppear{
    [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width,80.0)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    pisEmptyView = [[EmptyViewController alloc]init];
    pisGuestEMailData = [[NSMutableArray alloc]init];
    pisGuestPhoneData = [[NSMutableArray alloc]init];
    pisinvitedFromData = [[NSMutableArray alloc]init];
    pisinvitedTillData = [[NSMutableArray alloc]init];
    pisactionTakenData = [[NSMutableArray alloc]init];
    piskeyData = [[NSMutableArray alloc]init];
    
    
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_prevInvSentBack];
    
    

    
    
    piskeys = [[NSArray alloc]init];
    
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    //NSLog(@"DATE IS %@",[NSDate date]);
    
    
   NSDate *loginDate = [self dateToFormatedDate:[dateFormatter stringFromDate:[NSDate date]]];
    
    
    __block NSMutableArray *myGuestEMailData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myGuestPhoneData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedFromData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedTillData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myactionTakenData = [[NSMutableArray alloc] init];
    
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
    
   // NSLog(@"Current User Email %@",currentUserEMail);
   // NSLog(@"Current User Phone %@",currentUserPhone);
    
    
    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        NSString *endDateTime = [[NSString alloc] init];
        NSArray * arr = [dict allValues];
        piskeys = [dict allKeys];
        
        
       // NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        
        
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
           // NSLog(@"END DATE TIME %@",endDateTime);
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                fromDate:[self dateToFormatedDate:endDateTime]
                                                                  toDate:loginDate
                                                                 options:0];
            
            
            if([currentUserEMail length] > 0 && ([arr[i][@"Sender EMail"] isEqualToString:currentUserEMail]))
               //&& ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedDescending))
            {
                
               // NSLog(@"INSIDE EMAIL");
                
                if([components day] <= 15)
                {
                
                if([arr[i][@"Receiver EMail"] length] == 0) {
                    [myGuestEMailData addObject: @"Not Specified"];
                   // NSLog(@"Receiver E-Mail Empty");
                }
                
                else if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                }
                else {
                [myGuestEMailData addObject: @"Not Specified"];
                }
                
                if([arr[i][@"Receiver Phone"] length] == 0) {
                    [myGuestPhoneData addObject: @"Not Specified"];
                   // NSLog(@"Receiver Phone Empty");
                }
                
                else if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
                    [myGuestPhoneData addObject: arr[i][@"Receiver Phone"]];
                }
                else {
                    [myGuestPhoneData addObject: @"Not Specified"];
                }
                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [myactionTakenData addObject:arr[i][@"Invitation Status"]];
                [myKeyData addObject:piskeys[i]];
                continue;
                
            }
            }
            
            
            if([currentUserPhone length] > 0 && ([arr[i][@"Sender Phone"] isEqualToString:currentUserPhone]))
               //&& ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedDescending))
            {
                
                if([components day] <= 15)
                {
                
                if([arr[i][@"Receiver EMail"] length] == 0) {
                    [myGuestEMailData addObject: @"Not Specified"];
                   // NSLog(@"Receiver E-Mail Empty");
                }
                
                else if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                    [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                }
                
                else {
                    [myGuestEMailData addObject: @"Not Specified"];
                }
                
                if([arr[i][@"Receiver Phone"] length] == 0) {
                    [myGuestPhoneData addObject: @"Not Specified"];
                    //NSLog(@"Receiver Phone Empty");
                }
                
                else if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
                    [myGuestPhoneData addObject: arr[i][@"Receiver Phone"]];
                }
                else {
                    [myGuestPhoneData addObject: @"Not Specified"];
                }

                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [myactionTakenData addObject:arr[i][@"Invitation Status"]];
                [myKeyData addObject:piskeys[i]];
                
                continue;
                
            }
            
            }
            
            
            
            if(i == ([arr count]-1)){ // Check in case of last iteration and Add "No Invites" Only if no data is added to invites list
                
                
                //NSLog(@"Last Iteration");
                if([myGuestEMailData count]== 0 && [myGuestPhoneData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0)
                {
                    [myGuestEMailData addObject: @"No Invites"];
                    [myGuestPhoneData addObject: @"No Invites"];
                    [myinvitedFromData addObject: @"No Invites"];
                    [myinvitedTillData addObject: @"No Invites"];
                    [myactionTakenData addObject: @"No Invites"];
                    [myKeyData addObject:@"-1"];
                }
                
            }
            
            inviteTableIterator = i;
            
        }
        
    }];
    
    while([myinvitedFromData count]== 0 && [myinvitedTillData count]== 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    //NSLog(@"myinvitedFromData count is %lu",(unsigned long)[myinvitedFromData count]);
    for(int i =0;i<[myinvitedFromData count];i++){
        [pisGuestEMailData addObject:[myGuestEMailData objectAtIndex:i]];
        [pisGuestPhoneData addObject:[myGuestPhoneData objectAtIndex:i]];
        [pisinvitedFromData addObject:[myinvitedFromData objectAtIndex:i]];
        [pisinvitedTillData addObject:[myinvitedTillData objectAtIndex:i]];
        [pisactionTakenData addObject:[myactionTakenData objectAtIndex:i]];
        [piskeyData addObject:[myKeyData objectAtIndex:i]];
    }
    
       //NSLog(@"Key data is %@",piskeyData);

    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    
    return [pisinvitedFromData count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    

    [tableView registerNib:[UINib nibWithNibName:@"PrevInvSentCell" bundle:nil] forCellReuseIdentifier:@"PrevInvSentCell"];
    
    static NSString *cellIdentifier = @"PrevInvSentCell";
    
    
    
    PrevInvSentCell *cell = (PrevInvSentCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    

    
    /*
    // Add utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    
    cell.rightUtilityButtons = rightUtilityButtons;
    */
    cell.delegate = self;
    
    
    
    if(!([[pisGuestEMailData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
    cell.guestEMailLabel.text = [pisGuestEMailData objectAtIndex:indexPath.row];
    }
    
    else {
        cell.guestEMailLabel.text = @"Not Specified";
    }
    
    if(!([[pisGuestPhoneData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
        cell.guestPhoneLabel.text = [pisGuestPhoneData objectAtIndex:indexPath.row];
    }
    
    else {
        cell.guestPhoneLabel.text = @"Not Specified";
    }
    
    
    cell.invitedFromDateLabel.text = [pisinvitedFromData objectAtIndex:indexPath.row];
    cell.invitedTillDateLabel.text = [pisinvitedTillData objectAtIndex:indexPath.row];
    cell.actionTakenLabel.text = [pisactionTakenData objectAtIndex:indexPath.row];
    
    
    //if (indexPath.row % 2 == 0)
    //{
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    //}
   
   // else
     //   {
        
       /*
            cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"orange-1"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
            cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"orange-1"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];


    }
*/
    if([[piskeyData objectAtIndex:indexPath.row]integerValue] == -1){ // No entries in the Table
        
        [cell.guestEMail setHidden:YES];
        [cell.guestEMailLabel setHidden:YES];
        [cell.guestPhone setHidden:YES];
        [cell.guestPhoneLabel setHidden:YES];
        [cell.invitedFromDateLabel setHidden:YES];
        [cell.invitedTillDateLabel setHidden:YES];
        [cell.actionTakenLabel setHidden:YES];
        
        cell.userInteractionEnabled = NO;
        self.tableView.hidden = YES;
        self.prevInvSentBack.hidden = YES;
        pisEmptyView.view.frame = self.view.bounds;
        [self.view addSubview:pisEmptyView.view];
    }

    

    
    
    cell.userInteractionEnabled = NO;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 214;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
        {
            
            // LOGIC TO PERFORM DELETE OPERATION
            
            // Delete button is pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [pisGuestEMailData removeObjectAtIndex:cellIndexPath.row];
            [pisGuestPhoneData removeObjectAtIndex:cellIndexPath.row];
            [pisinvitedFromData removeObjectAtIndex:cellIndexPath.row];
            [pisinvitedTillData removeObjectAtIndex:cellIndexPath.row];
            [pisactionTakenData removeObjectAtIndex:cellIndexPath.row];
            [piskeyData removeObjectAtIndex:cellIndexPath.row];
            
            
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];

            
            
            break;
        }
        default:
            break;
    }
}


@end
