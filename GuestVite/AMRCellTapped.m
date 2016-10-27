//
//  AMRCellTapped.m
//  GuestVite
//
//  Created by admin on 2016-10-26.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AMRCellTapped.h"
#include "AwaitMyResponseViewController.h"

@import Firebase;

@interface AMRCellTapped ()
@property (weak, nonatomic) IBOutlet UILabel *invitedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedTillLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *personalMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *acceptOrDeclineLabel;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation AMRCellTapped

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.ref = [[FIRDatabase database] reference];
    self.invitedByLabel.text = [NSString stringWithFormat:@"%@ %@",_inviteByFirstName,_inviteByLastName];
    
    self.invitedOnLabel.text = _invitedOn;
    
    self.invitedTillLabel.text = _invitedTill;
    
    self.personalMessageLabel.text = _personalMessage;
    
    self.senderNameLabel.text = _inviteByFirstName;
    
    self.acceptOrDeclineLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)declineTapped:(id)sender {
    
    //NSString *pkey = [NSString stringWithFormat:@"%@",[[_ref child:@"invites"] child:_key]];
    
    
    
    [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        NSLog(@"DICT %@",dict);
        
        NSLog(@"Value Before decline %@" , [dict valueForKey:@"Invitation Status"]);
        NSDictionary *postDict = @{@"Sender First Name": [dict valueForKey:@"Sender First Name"],
                                   @"Sender Last Name": [dict valueForKey:@"Sender Last Name"],
                                   @"Sender EMail": [dict valueForKey:@"Sender EMail"],
                                   @"Sender Address1": [dict valueForKey:@"Sender Address1"],
                                   @"Sender Address2": [dict valueForKey:@"Sender Address2"],
                                   @"Sender City": [dict valueForKey:@"Sender City"],
                                   @"Sender Zip": [dict valueForKey:@"Sender Zip"],
                                   @"Sender Phone": [dict valueForKey:@"Sender Phone"],
                                   @"Mesage From Sender": [dict valueForKey:@"Mesage From Sender"],
                                   @"Receiver First Name": [dict valueForKey:@"Receiver First Name"],
                                   @"Receiver Last Name": [dict valueForKey:@"Receiver Last Name"],
                                   @"Receiver EMail": [dict valueForKey:@"Receiver EMail"],
                                   @"Receiver Phone": [dict valueForKey:@"Receiver Phone"],
                                   @"Invite For Date": [dict valueForKey:@"Invite For Date"],
                                   @"Invite Valid Till Date": [dict valueForKey:@"Invite Valid Till Date"],
                                   @"Invitation Status": @"Declined",
                                   };//Dict post
        
        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", _key]: postDict};
        [_ref updateChildValues:childUpdates];
        
        NSLog(@"Value After decline %@" , [dict valueForKey:@"Invitation Status"]);
        
        
    }];
    
    self.acceptOrDeclineLabel.text = @"Invitation Declined";
    self.acceptOrDeclineLabel.textColor = [UIColor redColor];
    
    
    [self performSelector:@selector(loadingNextView)
               withObject:nil afterDelay:3.0f];
}

- (IBAction)acceptTapped:(id)sender {
    
    [[[_ref child:@"invites"] child:_key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        
        NSDictionary *postDict = @{@"Sender First Name": [dict valueForKey:@"Sender First Name"],
                                   @"Sender Last Name": [dict valueForKey:@"Sender Last Name"],
                                   @"Sender EMail": [dict valueForKey:@"Sender EMail"],
                                   @"Sender Address1": [dict valueForKey:@"Sender Address1"],
                                   @"Sender Address2": [dict valueForKey:@"Sender Address2"],
                                   @"Sender City": [dict valueForKey:@"Sender City"],
                                   @"Sender Zip": [dict valueForKey:@"Sender Zip"],
                                   @"Sender Phone": [dict valueForKey:@"Sender Phone"],
                                   @"Mesage From Sender": [dict valueForKey:@"Mesage From Sender"],
                                   @"Receiver First Name": [dict valueForKey:@"Receiver First Name"],
                                   @"Receiver Last Name": [dict valueForKey:@"Receiver Last Name"],
                                   @"Receiver EMail": [dict valueForKey:@"Receiver EMail"],
                                   @"Receiver Phone": [dict valueForKey:@"Receiver Phone"],
                                   @"Invite For Date": [dict valueForKey:@"Invite For Date"],
                                   @"Invite Valid Till Date": [dict valueForKey:@"Invite Valid Till Date"],
                                   @"Invitation Status": @"Accepted",
                                   };//Dict post

        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", _key]: postDict};
        [_ref updateChildValues:childUpdates];
        
        
    }];
    
    self.acceptOrDeclineLabel.text = @"Invitation Accepted";
    self.acceptOrDeclineLabel.textColor = [UIColor greenColor];
    
    
    [self performSelector:@selector(loadingNextView)
               withObject:nil afterDelay:3.0f];
    
    
}


- (void)loadingNextView{
    
    
    AwaitMyResponseViewController *amrVC =
    [[AwaitMyResponseViewController alloc] initWithNibName:@"AwaitMyResponseViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:amrVC animated:YES];
    
    [self presentViewController:amrVC animated:YES completion:nil];
    
    
    
}
@end
