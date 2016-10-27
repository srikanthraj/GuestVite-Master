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
    
    self.invitedByLabel.text = [NSString stringWithFormat:@"%@ %@",_inviteByFirstName,_inviteByLastName];
    
    self.invitedOnLabel.text = _invitedOn;
    
    self.invitedTillLabel.text = _invitedTill;
    
    self.personalMessageLabel.text = _personalMessage;
    
    self.senderNameLabel.text = _inviteByFirstName;
    
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
    
    [self performSelector:@selector(loadingNextView)
               withObject:nil afterDelay:2.0f];
}

- (IBAction)acceptTapped:(id)sender {
    
    [self performSelector:@selector(loadingNextView)
               withObject:nil afterDelay:2.0f];
    
    
}


- (void)loadingNextView{
    
    
    AwaitMyResponseViewController *amrVC =
    [[AwaitMyResponseViewController alloc] initWithNibName:@"AwaitMyResponseViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:amrVC animated:YES];
    
    [self presentViewController:amrVC animated:YES completion:nil];
    
    
    
}
@end
