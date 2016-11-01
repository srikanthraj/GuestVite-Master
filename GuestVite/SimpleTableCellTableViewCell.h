//
//  SimpleTableCellTableViewCell.h
//  GuestVite
//
//  Created by admin on 2016-10-24.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
@import Firebase;

@interface SimpleTableCellTableViewCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *lastNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *invitedFromDateLabel;

@property (nonatomic, weak) IBOutlet UILabel *invitedTillDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedTillLabel;

@end
