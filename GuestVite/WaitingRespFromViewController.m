//
//  WaitingRespFromViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-31.
//  Copyright © 2016 admin. All rights reserved.
//

#import "WaitingRespFromViewController.h"
#import "PrevInvSentCell.h"

@import Firebase;

@interface WaitingRespFromViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UINavigationBar *waitingRespFromBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WaitingRespFromViewController


NSMutableArray *wrfGuestEMailData;
NSMutableArray *wrfGuestPhoneData;
NSMutableArray *wrfinvitedFromData;
NSMutableArray *wrfinvitedTillData;
NSMutableArray *wrfactionTakenData;

NSMutableArray *wrfkeyData;

NSArray *wrfkeys;


-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [dateFormatter setTimeZone:timeZone];
    return [dateFormatter dateFromString:dateStr];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    wrfGuestEMailData = [[NSMutableArray alloc]init];
    wrfGuestPhoneData = [[NSMutableArray alloc]init];
    wrfinvitedFromData = [[NSMutableArray alloc]init];
    wrfinvitedTillData = [[NSMutableArray alloc]init];
    wrfactionTakenData = [[NSMutableArray alloc]init];
    wrfkeyData = [[NSMutableArray alloc]init];
    
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Black_BG"]];
    self.tableView.backgroundColor = background;
    
    
    
    self.waitingRespFromBack = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 400, 64)];
    
    [self.waitingRespFromBack setFrame:CGRectMake(0, 0, 400, 64)];
    
    self.waitingRespFromBack.translucent = YES;
    
    
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
    
    [self.view addSubview:_waitingRespFromBack];
    
    
    
    wrfkeys = [[NSArray alloc]init];
    
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSLog(@"DATE IS %@",[NSDate date]);
    
    
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
        NSArray * arrUser = [dictUser allValues];
        
        currentUserEMail =  [NSString stringWithFormat:@"%@",arrUser[0]];
        currentUserPhone  = [NSString stringWithFormat:@"%@",arrUser[3]];
        
        
    }];
    while([currentUserEMail length]== 0 || [currentUserPhone length] ==0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    NSLog(@"Current User Email %@",currentUserEMail);
    NSLog(@"Current User Phone %@",currentUserPhone);
    
    
    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        NSString *endDateTime = [[NSString alloc] init];
        NSString *startDateTime = [[NSString alloc] init];
        NSArray * arr = [dict allValues];
        wrfkeys = [dict allKeys];
        
        
        NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        
        
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            startDateTime = arr[i][@"Invite For Date"];
            NSLog(@"END DATE TIME %@",endDateTime);
            
            if([currentUserEMail length] > 0 && ([arr[i][@"Sender EMail"] isEqualToString:currentUserEMail])
               && ([loginDate compare:[self dateToFormatedDate:startDateTime]] == NSOrderedDescending) && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending) && [arr[i][@"Invitation Status"] isEqualToString:@"Pending"])
            {
                
                NSLog(@"INSIDE EMAIL");
                
                if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                    [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                    NSLog(@"Receiver E-Mail NOT BULK");
                }
                if([arr[i][@"Receiver EMail"] length] == 0) {
                    [myGuestEMailData addObject: @"Not Specified"];
                    NSLog(@"Receiver E-Mail Empty");
                }
                else {
                    [myGuestEMailData addObject: @"Not Specified"];
                    NSLog(@"Receiver E-Mail BULK");
                }
                
                if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
                    [myGuestPhoneData addObject: arr[i][@"Receiver Phone"]];
                    NSLog(@"Receiver Phone NOT BULK");
                }
                else {
                    [myGuestPhoneData addObject: @"Not Specified"];
                    NSLog(@"Receiver Phone BULK");
                }
                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [myactionTakenData addObject:arr[i][@"Invitation Status"]];
                [myKeyData addObject:wrfkeys[i]];
                continue;
                
            }
            
            
            
            if([currentUserPhone length] > 0 && ([arr[i][@"Sender Phone"] isEqualToString:currentUserPhone])
               && ([loginDate compare:[self dateToFormatedDate:startDateTime]] == NSOrderedDescending)&& ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending)&& [arr[i][@"Invitation Status"] isEqualToString:@"Pending"])
            {
                
                if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                    [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                    NSLog(@"Receiver E-Mail NOT BULK");
                }
                else {
                    [myGuestEMailData addObject: @"Not Specified"];
                    NSLog(@"Receiver E-Mail BULK");
                }
                
                if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
                    [myGuestPhoneData addObject: arr[i][@"Receiver Phone"]];
                    NSLog(@"Receiver Phone NOT BULK");
                }
                else {
                    [myGuestPhoneData addObject: @"Not Specified"];
                    NSLog(@"Receiver Phone BULK");
                }
                
                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [myactionTakenData addObject:arr[i][@"Invitation Status"]];
                [myKeyData addObject:wrfkeys[i]];
                
                continue;
                
            }
            
            
            
            
            
            if(i == ([arr count]-1)){ // Check in case of last iteration and Add "No Invites" Only if no data is added to invites list
                
                
                NSLog(@"Last Iteration");
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
    
    NSLog(@"myinvitedFromData count is %lu",(unsigned long)[myinvitedFromData count]);
    for(int i =0;i<[myinvitedFromData count];i++){
        [wrfGuestEMailData addObject:[myGuestEMailData objectAtIndex:i]];
        [wrfGuestPhoneData addObject:[myGuestPhoneData objectAtIndex:i]];
        [wrfinvitedFromData addObject:[myinvitedFromData objectAtIndex:i]];
        [wrfinvitedTillData addObject:[myinvitedTillData objectAtIndex:i]];
        [wrfactionTakenData addObject:[myactionTakenData objectAtIndex:i]];
        [wrfkeyData addObject:[myactionTakenData objectAtIndex:i]];
    }
    
        NSLog(@"Guest E-Mail data is %@",wrfGuestEMailData);
     NSLog(@"Guest Phone data is %@",wrfGuestPhoneData);
    
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
    
    return [wrfinvitedFromData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView registerNib:[UINib nibWithNibName:@"PrevInvSentCell" bundle:nil] forCellReuseIdentifier:@"PrevInvSentCell"];
    
    static NSString *cellIdentifier = @"PrevInvSentCell";
    
    
    
    PrevInvSentCell *cell = (PrevInvSentCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    // Add utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    
    
    if(!([[wrfGuestEMailData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
        cell.guestEMailLabel.text = [wrfGuestEMailData objectAtIndex:indexPath.row];
    }
    
    else {
        [cell.guestEMailLabel setHidden:TRUE];
        [cell.guestEMail setHidden:TRUE];
    }
    
    if(!([[wrfGuestPhoneData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
        cell.guestPhoneLabel.text = [wrfGuestPhoneData objectAtIndex:indexPath.row];
    }
    
    else {
        [cell.guestPhoneLabel setHidden:TRUE];
        [cell.guestPhone setHidden:TRUE];
    }
    
    
    cell.invitedFromDateLabel.text = [wrfinvitedFromData objectAtIndex:indexPath.row];
    cell.invitedTillDateLabel.text = [wrfinvitedTillData objectAtIndex:indexPath.row];
    cell.actionTakenLabel.text = [wrfactionTakenData objectAtIndex:indexPath.row];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"Black_BG"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"Black_BG"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    
    cell.userInteractionEnabled = NO;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 214;
}

@end
