//
//  TrackMyGuestsViewController.m
//  GuestVite
//
//  Created by admin on 2016-11-06.
//  Copyright © 2016 admin. All rights reserved.
//

#import "TrackMyGuestsViewController.h"
#import "AcceptedGuestsCellTapped.h"
#import "TrackMyGuestsCellTapped.h"

@import Firebase;

@interface TrackMyGuestsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *trackMyGuestsBack;

@end

@implementation TrackMyGuestsViewController


NSMutableArray *tmgGuestEMailData;
NSMutableArray *tmgGuestPhoneData;
NSMutableArray *tmginvitedFromData;
NSMutableArray *tmginvitedTillData;


NSMutableArray *hostLatitudeData;
NSMutableArray *hostLongitudeData;
NSMutableArray *guestLatitudeData;
NSMutableArray *guestLongitudeData;


NSMutableArray *tmgkeyData;

NSArray *tmgkeys;



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
    // Do any additional setup after loading the view from its nib.
    
    
    tmgGuestEMailData = [[NSMutableArray alloc]init];
    tmgGuestPhoneData = [[NSMutableArray alloc]init];
    tmginvitedFromData = [[NSMutableArray alloc]init];
    tmginvitedTillData = [[NSMutableArray alloc]init];
    tmgkeyData = [[NSMutableArray alloc]init];
    
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Black_BG"]];
    self.tableView.backgroundColor = background;
    
    
    self.trackMyGuestsBack = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 400, 64)];
    
    [self.trackMyGuestsBack setFrame:CGRectMake(0, 0, 400, 64)];
    
    self.trackMyGuestsBack.translucent = YES;
    
    
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
    
    [self.view addSubview:_trackMyGuestsBack];

    tmgkeys = [[NSArray alloc]init];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    
    NSDate *loginDate = [self dateToFormatedDate:[dateFormatter stringFromDate:[NSDate date]]];
    
    __block NSMutableArray *myGuestEMailData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myGuestPhoneData = [[NSMutableArray alloc] init];
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
        tmgkeys = [dict allKeys];
        
        
        NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        
        
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            startDateTime = arr[i][@"Invite For Date"];
            //NSLog(@"EMail %lu",[arr[i][@"Receiver EMail"] length]);
            
            if([currentUserEMail length] > 0 && ([arr[i][@"Sender EMail"] isEqualToString:currentUserEMail])
               && ([loginDate compare:[self dateToFormatedDate:startDateTime]] == NSOrderedDescending)
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending) && [arr[i][@"Invitation Status"] isEqualToString:@"Accepted"])
            {
                
                NSLog(@"INVITED FROM DATE TIME %@",startDateTime);
                NSLog(@"INVITED TILL DATE TIME %@",endDateTime);
                
                if([arr[i][@"Receiver EMail"] length] == 0) {
                    [myGuestEMailData addObject: @"Not Specified"];
                  //  NSLog(@"Receiver E-Mail Empty");
                }
                else if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                    [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                    //NSLog(@"Receiver E-Mail NOT BULK");
                }
                
                else {
                    [myGuestEMailData addObject: @"Not Specified"];
                    //NSLog(@"Receiver E-Mail BULK");
                }
                
                if([arr[i][@"Receiver Phone"] length] == 0) {
                    [myGuestPhoneData addObject: @"Not Specified"];
                    //NSLog(@"Receiver Phone Empty");
                }
                
                else if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
                    [myGuestPhoneData addObject: arr[i][@"Receiver Phone"]];
                    //NSLog(@"Receiver Phone NOT BULK");
                }
                
                
                else {
                    [myGuestPhoneData addObject: @"Not Specified"];
                    //NSLog(@"Receiver Phone BULK");
                }
                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [myKeyData addObject:tmgkeys[i]];
                continue;
                
            }
            
            
            
            if([currentUserPhone length] > 0 && ([arr[i][@"Sender Phone"] isEqualToString:currentUserPhone])
               && ([loginDate compare:[self dateToFormatedDate:startDateTime]] == NSOrderedDescending)
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending)&& [arr[i][@"Invitation Status"] isEqualToString:@"Accepted"])
            {
                
                NSLog(@"INVITED FROM DATE TIME %@",startDateTime);
                NSLog(@"INVITED TILL DATE TIME %@",endDateTime);
                
                if([arr[i][@"Receiver EMail"] length] == 0) {
                    [myGuestEMailData addObject: @"Not Specified"];
                    //NSLog(@"Receiver E-Mail Empty");
                }
                
                else if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                    [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                    //NSLog(@"Receiver E-Mail NOT BULK");
                }
                
                else {
                    [myGuestEMailData addObject: @"Not Specified"];
                    //NSLog(@"Receiver E-Mail BULK");
                }
                
                if([arr[i][@"Receiver Phone"] length] == 0) {
                    [myGuestPhoneData addObject: @"Not Specified"];
                    //NSLog(@"Receiver Phone Empty");
                }
                
                else if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
                    [myGuestPhoneData addObject: arr[i][@"Receiver Phone"]];
                    //NSLog(@"Receiver Phone NOT BULK");
                }
                
                else {
                    [myGuestPhoneData addObject: @"Not Specified"];
                    //NSLog(@"Receiver Phone BULK");
                }
                
                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [myKeyData addObject:tmgkeys[i]];
                
                continue;
                
            }
            
            
            
            
            
            if(i == ([arr count]-1)){ // Check in case of last iteration and Add "No Invites" Only if no data is added to invites list
                
                
               
                if([myGuestEMailData count]== 0 && [myGuestPhoneData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0)
                {
                    [myGuestEMailData addObject: @"No Invites"];
                    [myGuestPhoneData addObject: @"No Invites"];
                    [myinvitedFromData addObject: @"No Invites"];
                    [myinvitedTillData addObject: @"No Invites"];
                    [myKeyData addObject:@"-1"];
                }
                
            }
            
            inviteTableIterator = i;
            
        }
        
    }];
    
    while([myinvitedFromData count]== 0 && [myinvitedTillData count]== 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    
    
    for(int i =0;i<[myinvitedFromData count];i++){
        [tmgGuestEMailData addObject:[myGuestEMailData objectAtIndex:i]];
        [tmgGuestPhoneData addObject:[myGuestPhoneData objectAtIndex:i]];
        [tmginvitedFromData addObject:[myinvitedFromData objectAtIndex:i]];
        [tmginvitedTillData addObject:[myinvitedTillData objectAtIndex:i]];
        [tmgkeyData addObject:[myKeyData objectAtIndex:i]];
    }
    
     NSLog(@"Key data is %@",tmgGuestEMailData);
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
    
    return [tmginvitedFromData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView registerNib:[UINib nibWithNibName:@"AcceptedGuestsCellTapped" bundle:nil] forCellReuseIdentifier:@"AcceptedGuestsCellTapped"];
    
    static NSString *cellIdentifier = @"AcceptedGuestsCellTapped";
    
    
    
    AcceptedGuestsCellTapped *cell = (AcceptedGuestsCellTapped *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    
   // cell.delegate = self;
    
    
    if(!([[tmgGuestEMailData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
        cell.guestEMailLabel.text = [tmgGuestEMailData objectAtIndex:indexPath.row];
    }
    
    else {
        [cell.guestEMailLabel setHidden:TRUE];
        [cell.guestEMail setHidden:TRUE];
    }
    
    if(!([[tmgGuestPhoneData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
        cell.guestPhoneLabel.text = [tmgGuestPhoneData objectAtIndex:indexPath.row];
    }
    
    else {
        [cell.guestPhoneLabel setHidden:TRUE];
        [cell.guestPhone setHidden:TRUE];
    }
    
    
    cell.invitedFromDateLabel.text = [tmginvitedFromData objectAtIndex:indexPath.row];
    cell.invitedTillDateLabel.text = [tmginvitedTillData objectAtIndex:indexPath.row];

    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"Black_BG"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"Black_BG"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    
    //cell.userInteractionEnabled = NO;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSLog(@"Cell Tapped");
    
    TrackMyGuestsCellTapped *tmgCellTapped =
    [[TrackMyGuestsCellTapped alloc] initWithNibName:@"TrackMyGuestsCellTapped" bundle:nil];
    
    tmgCellTapped.key = [tmgkeyData objectAtIndex:indexPath.row];
    

    [self.navigationController pushViewController:tmgCellTapped animated:YES];
    
    [self presentViewController:tmgCellTapped animated:YES completion:nil];
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
