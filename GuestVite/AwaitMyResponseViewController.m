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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __block NSMutableArray *myfirstNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *mylastNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedFromData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedTillData = [[NSMutableArray alloc] init];
    
    self.ref = [[FIRDatabase database] reference];
    
    
    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        NSArray * arr = [dict allValues];
        NSLog(@"Array %@",arr[0][@"Sender First Name"]);
        
        for(int i=0;i < [arr count];i++)
        {
            [arr[i][@"SF"] appendFormat:@"%@",arr[i][@"SL"]];
            
        [myfirstNameData setObject: arr[i][@"Sender First Name"] atIndexedSubscript:i];
        [mylastNameData setObject:arr[i][@"Sender Last Name"] atIndexedSubscript:i];
        [myinvitedFromData setObject:arr[i][@"Invite For Date"] atIndexedSubscript:i];
        [myinvitedTillData setObject:arr[i][@"Invite Valid Till Date"] atIndexedSubscript:i];
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
                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
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




@end
