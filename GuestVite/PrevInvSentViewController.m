//
//  PrevInvSentViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-30.
//  Copyright © 2016 admin. All rights reserved.
//

#import "PrevInvSentViewController.h"
#import "PrevInvSentCell.h"

@import Firebase;

@interface PrevInvSentViewController () <UITableViewDelegate, UITableViewDataSource,SWTableViewCellDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *prevInvSentBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;

@end

@implementation PrevInvSentViewController

NSMutableArray *pisGuestEMailData;
NSMutableArray *pisGuestPhoneData;
NSMutableArray *pisnameData;
NSMutableArray *pisinvitedFromData;
NSMutableArray *pisinvitedTillData;
NSMutableArray *pisactionTakenData;

NSMutableArray *piskeyData;

NSArray *piskeys;


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
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Black_BG"]];
    self.tableView.backgroundColor = background;
    

    
    self.prevInvSentBack = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 400, 64)];
    
    [self.prevInvSentBack setFrame:CGRectMake(0, 0, 400, 64)];
    
    self.prevInvSentBack.translucent = YES;
    
    
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
    /*
    
    // Change the appearance of back button
     
     UIImage *backButtonImage = [[UIImage imageNamed:@"button_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 6)];
     
     [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
     
     // Change the appearance of other navigation button
     UIImage *barButtonImage = [[UIImage imageNamed:@"button_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
     
     [[UIBarButtonItem appearance] setBackgroundImage:barButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    
    [[UIBarButtonItem appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                          NSForegroundColorAttributeName,
                                                          [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],nil] forState:UIControlStateNormal];

    
    
    
    
    */
     
    [self.view addSubview:_prevInvSentBack];
    
    

    
    
    piskeys = [[NSArray alloc]init];
    
    
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
        NSArray * arr = [dict allValues];
        piskeys = [dict allKeys];
        
        
        NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        
        
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            NSLog(@"END DATE TIME %@",endDateTime);
            
            if([currentUserEMail length] > 0 && ([arr[i][@"Sender EMail"] isEqualToString:currentUserEMail])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedDescending))
            {
                
                NSLog(@"INSIDE EMAIL");
                
                if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                }
                else {
                [myGuestEMailData addObject: @"Not Specified"];
                }
                
                if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
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
            
            
            
            if([currentUserPhone length] > 0 && ([arr[i][@"Sender Phone"] isEqualToString:currentUserPhone])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedDescending))
            {
                
                if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                    [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                }
                else {
                    [myGuestEMailData addObject: @"Not Specified"];
                }
                
                if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
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
    
    
    pisGuestEMailData = [myGuestEMailData copy];
    pisGuestPhoneData = [myGuestPhoneData copy];
    pisinvitedFromData = [myinvitedFromData copy];
    pisinvitedTillData = [myinvitedTillData copy];
    pisactionTakenData = [myactionTakenData copy];
    piskeyData = [myKeyData copy];
    
    NSLog(@"Key data is %@",piskeyData);

    
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
    
    
    // Add utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    
    
    if(!([[pisGuestEMailData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
    cell.guestEMailLabel.text = [pisGuestEMailData objectAtIndex:indexPath.row];
    }
    
    else {
        [cell.guestEMailLabel setHidden:TRUE];
        [cell.guestEMail setHidden:TRUE];
    }
    
    if(!([[pisGuestPhoneData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
        cell.guestPhoneLabel.text = [pisGuestPhoneData objectAtIndex:indexPath.row];
    }
    
    else {
        [cell.guestPhoneLabel setHidden:TRUE];
        [cell.guestPhone setHidden:TRUE];
    }
    
    
    cell.invitedFromDateLabel.text = [pisinvitedFromData objectAtIndex:indexPath.row];
    cell.invitedTillDateLabel.text = [pisinvitedTillData objectAtIndex:indexPath.row];
    cell.actionTakenLabel.text = [pisactionTakenData objectAtIndex:indexPath.row];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"Black_BG"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"Black_BG"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    
    
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
            
            
            break;
        }
        default:
            break;
    }
}


@end
