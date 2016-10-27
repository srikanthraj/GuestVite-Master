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
    
    keys = [[NSArray alloc]init];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSLog(@"DATE IS %@",[NSDate date]);
    
    
    NSDate *loginDate = [self dateToFormatedDate:[dateFormatter stringFromDate:[NSDate date]]];
    
    /*
    firstNameData = [[NSMutableArray alloc] init];;
    lastNameData = [[NSMutableArray alloc] init];
    invitedFromData = [[NSMutableArray alloc] init];
    invitedTillData = [[NSMutableArray alloc] init];
    */
     
    __block NSMutableArray *myfirstNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *mylastNameData = [[NSMutableArray alloc] init];
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
    
    NSLog(@"Current User Email %@",currentUserEMail);
    NSLog(@"Current User Phone %@",currentUserPhone);


    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        //NSString *startDateTime  = [[NSString alloc] init];
        NSString *endDateTime = [[NSString alloc] init];
        NSArray * arr = [dict allValues];
        keys = [dict allKeys];
        //NSLog(@"Array %@",arr[0][@"Sender First Name"]);
        
        NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        //NSLog(@"ARR count %lu",(unsigned long)[arr count]);
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            
            NSLog(@"PESONAl MESSAGE at iteattion %d IS %@",i,arr[i][@"Mesage From Sender"]);
                
            if([currentUserEMail length] > 0 && [arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && ([arr[i][@"Receiver EMail"] isEqualToString:currentUserEMail])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending))
            {
                
                NSLog(@"INSIDE EMAIL");
            
                [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                [mylastNameData addObject:arr[i][@"Sender Last Name"]];
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
                    [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                    [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                    [myPersonalMessageData addObject:arr[i][@"Mesage From Sender"]];
                    [myKeyData addObject:keys[i]];
                    
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
                    [myPersonalMessageData addObject: @"No Invites"];
                    [myKeyData addObject:@"-1"];
                }
                
            }
            
            inviteTableIterator = i;
            
        }
        
    }];
    
    while([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
   
    NSLog(@"Class %@",NSStringFromClass([firstNameData class]));
    
    
    //NSLog(@"My Data count %lu", (unsigned long)[myData count]);
    /*
    for(int i=0;i<[myfirstNameData count];i++){
        [firstNameData addObject:[myfirstNameData objectAtIndex:i]];
        [lastNameData addObject:[mylastNameData objectAtIndex:i]];
        [invitedFromData addObject:[myinvitedFromData objectAtIndex:i]];
        [invitedTillData addObject:[myinvitedTillData objectAtIndex:i]];
    }
     */
    
    
    
        /*
         
         firstNameData = [NSMutableArray arrayWithArray:myfirstNameData];
         lastNameData = [NSMutableArray arrayWithArray:mylastNameData];
         invitedFromData = [NSMutableArray arrayWithArray:myinvitedFromData];
         invitedTillData = [NSMutableArray arrayWithArray:myinvitedTillData];
         
         firstNameData = [[NSMutableArray alloc] initWithArray:myfirstNameData copyItems:YES];
         lastNameData = [[NSMutableArray alloc] initWithArray:mylastNameData copyItems:YES];
         invitedFromData = [[NSMutableArray alloc] initWithArray:myinvitedFromData copyItems:YES];;
         invitedTillData = [[NSMutableArray alloc] initWithArray:myinvitedTillData copyItems:YES];;
         */

    firstNameData = [myfirstNameData copy];
    lastNameData = [mylastNameData copy];
    invitedFromData = [myinvitedFromData copy];
    invitedTillData = [myinvitedTillData copy];
    personalMessageData = [myPersonalMessageData copy];
    keyData = [myKeyData copy];
   
    NSLog(@"Key data is %@",keyData);
    
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
    
    if([[keyData objectAtIndex:indexPath.row]integerValue] == -1){
        NSLog(@"NOOO INVITE");
        cell.userInteractionEnabled = NO;
    }
    return cell;
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
                
               
                
                for(int i=0;i<[arr count];i++){
                    
                    
                    if([arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && [[invitedFromData objectAtIndex:cellIndexPath.row] isEqualToString:arr[i][@"Invite For Date"]])
                       
                    { // If status is pending  and From date in table matches the one from the table
                        
                        /*
                        //Update the UI
                        NSLog(@"GOING to REMOVE %@ , %@, %@, %@",[invitedFromData objectAtIndex:cellIndexPath.row],[invitedTillData objectAtIndex:cellIndexPath.row],[firstNameData objectAtIndex:cellIndexPath.row],[lastNameData objectAtIndex:cellIndexPath.row]);
                        
                        [invitedFromData removeObjectAtIndex:cellIndexPath.row];
                        [invitedTillData removeObjectAtIndex:cellIndexPath.row];
                        [firstNameData removeObjectAtIndex:cellIndexPath.row];
                        [lastNameData removeObjectAtIndex:cellIndexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                        */
                        
                        //Update the data Model : Firebase in this case
                        
                        [self.tableView reloadData];
                        
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
                        
                        
                        //Update the UI
                        /*
                        [invitedFromData removeObjectAtIndex:cellIndexPath.row];
                        [invitedTillData removeObjectAtIndex:cellIndexPath.row];
                        [firstNameData removeObjectAtIndex:cellIndexPath.row];
                        [lastNameData removeObjectAtIndex:cellIndexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                        */
                        
                        [self.tableView reloadData];
                        
                        
                        //Update the data Model : Firebase in this case
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
