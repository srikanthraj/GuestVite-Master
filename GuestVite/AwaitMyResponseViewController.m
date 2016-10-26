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
    return [dateFormatter dateFromString:dateStr];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    //NSLog(@"DATE IS %@",[dateFormatter stringFromDate:[NSDate date]]);
    
    NSDate *loginDate = [self dateToFormatedDate:[dateFormatter stringFromDate:[NSDate date]]];
    
    __block NSMutableArray *myfirstNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *mylastNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedFromData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedTillData = [[NSMutableArray alloc] init];
    
    __block NSString *currentUserEMail = [[NSString alloc] init];
    __block NSString *currentUserPhone = [[NSString alloc] init];
    
    self.ref = [[FIRDatabase database] reference];
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dictUser = snapshot.value;
         NSArray * arrUser = [dictUser allValues];
        NSLog(@"ARR USER %@",arrUser);
        
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
        NSLog(@"Array %@",arr[0][@"Sender First Name"]);
        
       // NSLog(@"ARR count %lu",(unsigned long)[arr count]);
        for(int i=0;i < [arr count];i++)
        {
            //startDateTime = arr[i][@"Invite For Date"];
            endDateTime = arr[i][@"Invite Valid Till Date"];
            //[self dateToFormatedDate:startDateTime];
            //;
            //NSLog(@"End Date time in the loop %@",endDateTime);
            
            if([currentUserEMail length] > 0) // If user logged in via e_mail
            {
                
                
            if([arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && ([arr[i][@"Receiver EMail"] isEqualToString:currentUserEMail]) && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending))
            {
            
                [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                [mylastNameData addObject:arr[i][@"Sender Last Name"]];
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                
                
            }
            
        }
            
            else if ([currentUserPhone length] > 0)
            {
                
                if([arr[i][@"Invitation Status"] isEqualToString:@"Pending"] && ([arr[i][@"Receiver Phone"] isEqualToString:currentUserPhone]) && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending))
                {
                    
                    [myfirstNameData setObject: arr[i][@"Sender First Name"] atIndexedSubscript:i];
                    [mylastNameData setObject:arr[i][@"Sender Last Name"] atIndexedSubscript:i];
                    [myinvitedFromData setObject:arr[i][@"Invite For Date"] atIndexedSubscript:i];
                    [myinvitedTillData setObject:arr[i][@"Invite Valid Till Date"] atIndexedSubscript:i];
                }
                
                
            }
            
            
            
            
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
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Accepted Successfully"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            break;
        }
        case 1:
        {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Declined Successfully"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];

            break;
        }
        default:
            break;
    }
}


@end
