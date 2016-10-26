//
//  AwaitMyResponseViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-24.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AwaitMyResponseViewController.h"
#import "SimpleTableCellTableViewCell.h"

@import Firebase;


@interface AwaitMyResponseViewController () <UITableViewDelegate, UITableViewDataSource,SWTableViewCellDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AwaitMyResponseViewController


 NSMutableArray *firstNameData;
 NSMutableArray *lastNameData;
 NSMutableArray *nameData;
 NSMutableArray *invitedFromData;
 NSMutableArray *invitedTillData;


-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
   
    [dateFormatter setTimeZone:timeZone];
    return [dateFormatter dateFromString:dateStr];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSLog(@"DATE IS %@",[NSDate date]);
    
    
    NSDate *loginDate = [self dateToFormatedDate:[dateFormatter stringFromDate:[NSDate date]]];
    
    __block NSMutableArray *myfirstNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *mylastNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedFromData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedTillData = [[NSMutableArray alloc] init];
    
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
    
    NSLog(@"Current User Email %@",currentUserEMail);
    NSLog(@"Current User Phone %@",currentUserPhone);


    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        //NSString *startDateTime  = [[NSString alloc] init];
        NSString *endDateTime = [[NSString alloc] init];
        NSArray * arr = [dict allValues];
        //NSLog(@"Array %@",arr[0][@"Sender First Name"]);
        
        NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        //NSLog(@"ARR count %lu",(unsigned long)[arr count]);
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            NSLog(@"END DATE IS %@",[self dateToFormatedDate:endDateTime]);
                
            if([currentUserEMail length] > 0 && [arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && ([arr[i][@"Receiver EMail"] isEqualToString:currentUserEMail])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending))
            {
                
                NSLog(@"INSIDE EMAIL");
            
                [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                [mylastNameData addObject:arr[i][@"Sender Last Name"]];
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                continue;
                
            }
            
            
                
                if([currentUserPhone length] > 0 && [arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && ([arr[i][@"Receiver Phone"] isEqualToString:currentUserPhone])
                   && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending))
                {
                    
                    [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                    [mylastNameData addObject:arr[i][@"Sender Last Name"]];
                    [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                    [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                    
                    continue;
                    
                }
                
                
                
                
            
            if(i == ([arr count]-1)){ // Check in case of last iteration and Add "No Invites" Only if no data is added to invites list
                
                
                    NSLog(@"Last Iteration");
                if([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0)
                {
                    [myfirstNameData addObject: @"No Invites"];
                    [mylastNameData addObject: @"No Invites"];
                    [myinvitedFromData addObject: @"No Invites"];
                    [myinvitedTillData addObject: @"No Invites"];
                }
                
            }
            
            inviteTableIterator = i;
            
        }
        
    }];
    
    while([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
   
    //NSLog(@"My Data count %lu", (unsigned long)[myData count]);
    firstNameData = [myfirstNameData copy];
    lastNameData = [mylastNameData copy];
    invitedFromData = [myinvitedFromData copy];
    invitedTillData = [myinvitedTillData copy];
    
     NSLog(@"First Name data is %@",firstNameData);
     NSLog(@"Last Name data is %@",lastNameData);
    NSLog(@"From Date data is %@",invitedFromData);
    NSLog(@"Till Date  data is %@",invitedTillData);
    // Do any additional setup after loading the view from its nib.
    
    
   
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
    
    return cell;
}



            

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145;
}



- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
        {
            
            
            // Case of Invite accepted - Update the status to ACCEPTED
             NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                NSDictionary *dict = snapshot.value;
                NSArray *keys = [dict allKeys];
                NSArray * arr = [dict allValues];
                
               
                
                for(int i=0;i<[arr count];i++){
                    
                    
                    if([arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && [[invitedFromData objectAtIndex:cellIndexPath.row] isEqualToString:arr[i][@"Invite For Date"]])
                       
                    { // If status is pending  and From date in table matches the one from the table
                        
                         NSLog(@"KEYS AT INDEX!! %@",keys[i]);
                        
                    arr[i][@"Invitation Status"] = @"Accepted";
                        NSLog(@"Status Changed %@", arr[i][@"Invitation Status"]);
                        
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
                        NSLog(@"POST DIC %@",postDict);
                        
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", keys[i]]: postDict};
                        [_ref updateChildValues:childUpdates];
                    }

                }
            }];
            
            
            
            
            
            break;
        }
        case 1:
        {
            // Case of Invite accepted - Update the status to DECLINED
             NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                NSDictionary *dict = snapshot.value;
                NSArray *keys = [dict allKeys];
                NSArray * arr = [dict allValues];
                
               
                
                for(int i=0;i<[arr count];i++){
                    
                    NSLog(@"CELL INDEX %ld",cellIndexPath.row);
                    
                    if([arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && [[invitedFromData objectAtIndex:cellIndexPath.row] isEqualToString:arr[i][@"Invite For Date"]])
                    { // If status is pending  and From date in table matches the one from the table
                        
                        NSLog(@"KEYS AT INDEX!! %@",keys[i]);
                        
                        arr[i][@"Invitation Status"] = @"Declined";
                        NSLog(@"Status Changed %@", arr[i][@"Invitation Status"]);
                        
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
                        NSLog(@"POST DIC %@",postDict);
                        
                        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", keys[i]]: postDict};
                        [_ref updateChildValues:childUpdates];
                    }
                    
                }
            }];

            break;
        }
        default:
            break;
    }
}


@end
